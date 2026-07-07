module "networking" {
  source = "./modules/networking"

  name                 = var.project_name
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}

module "ecr_frontend" {
  source = "./modules/ecr"

  repository_name = var.frontend_ecr_repository_name
}

module "ecr_backend" {
  source = "./modules/ecr"

  repository_name = var.backend_ecr_repository_name
}

module "backend" {
  source = "./modules/ecs_service"

  service_name                   = "backend"
  cluster_name                   = aws_ecs_cluster.this.name
  container_image                = var.backend_image != "" ? var.backend_image : module.ecr_backend.repository_url
  container_port                 = 8000
  aws_region                     = var.region
  vpc_id                         = module.networking.vpc_id
  public_subnets                 = module.networking.public_subnet_ids
  private_subnets                = module.networking.private_subnet_ids
  create_alb                     = true
  alb_internal                   = true
  alb_ingress_cidrs              = [var.vpc_cidr]
  alb_ingress_security_group_ids = [module.frontend.task_security_group_id]
  ingress_security_group_ids     = [module.frontend.task_security_group_id]
  container_environment = {
    DB_HOST     = module.database.endpoint
    DB_USER     = var.database_username
    DB_PASSWORD = var.database_password
    DB_NAME     = var.database_name
    DB_PORT     = "3306"
  }
}

module "frontend" {
  source = "./modules/ecs_service"

  service_name               = "frontend"
  cluster_name               = aws_ecs_cluster.this.name
  container_image            = var.frontend_image != "" ? var.frontend_image : module.ecr_frontend.repository_url
  container_port             = 80
  aws_region                 = var.region
  vpc_id                     = module.networking.vpc_id
  public_subnets             = module.networking.public_subnet_ids
  private_subnets            = module.networking.private_subnet_ids
  create_alb                 = true
  alb_ingress_cidrs          = ["0.0.0.0/0"]
  ingress_security_group_ids = []
  container_environment = {
    BACKEND_HOST = module.backend.alb_dns_name
  }
}

module "database" {
  source = "./modules/rds"

  name                       = "${var.project_name}-db"
  db_name                    = var.database_name
  username                   = var.database_username
  password                   = var.database_password
  vpc_id                     = module.networking.vpc_id
  private_subnets            = module.networking.private_subnet_ids
  allowed_security_group_ids = [module.backend.task_security_group_id]
}
