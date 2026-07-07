resource "aws_iam_role" "execution" {
  name = "${var.service_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
}

resource "aws_security_group" "task" {
  name        = "${var.service_name}-task-sg"
  description = "Allow traffic for ${var.service_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.service_name}-task-sg"
  }
}

resource "aws_security_group_rule" "task_ingress_from_alb" {
  count                    = var.create_alb ? 1 : 0
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb[0].id
  security_group_id        = aws_security_group.task.id
}

resource "aws_security_group_rule" "task_ingress_from_sgs" {
  count                    = length(var.ingress_security_group_ids)
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.ingress_security_group_ids[count.index]
  security_group_id        = aws_security_group.task.id
}

resource "aws_security_group_rule" "task_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.task.id
}

resource "aws_security_group" "alb" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.service_name}-alb-sg"
  description = "Allow HTTP access to ${var.service_name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_from_sgs" {
  count                    = var.create_alb ? length(var.alb_ingress_security_group_ids) : 0
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.alb_ingress_security_group_ids[count.index]
  security_group_id        = aws_security_group.alb[0].id
}

resource "aws_lb" "this" {
  count              = var.create_alb ? 1 : 0
  name               = "${var.service_name}-alb"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.service_name}-alb"
  }
}

resource "aws_lb_target_group" "this" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

locals {
  container_environment_entries = [for key, value in var.container_environment : {
    name  = key
    value = value
  }]

  container_definition = jsonencode([
    {
      name        = var.service_name
      image       = var.container_image
      essential   = true
      environment = local.container_environment_entries
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.service_name
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.execution.arn
  container_definitions    = local.container_definition
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.create_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  depends_on = [aws_lb_listener.http]
}
