resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Allow database traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db-sg"
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az                = false
  port                    = 3306

  tags = {
    Name = var.name
  }
}
