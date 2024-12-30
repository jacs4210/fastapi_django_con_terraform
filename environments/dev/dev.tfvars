# Variables generales
environment = "dev"
region      = "us-east-1"

# RDS Configuración
rds_instance_class     = "db.t3.small"
rds_allocated_storage  = 20
rds_engine_version     = "15.4"
rds_master_username    = "dev_admin"
rds_master_password    = "devpassword123"
rds_backup_retention   = 7
rds_multi_az           = false
rds_public_accessible  = false

# Bucket S3 para estado remoto
terraform_s3_bucket_name = "dev-bucket-terraform"
terraform_dynamodb_table = "dev-terraform-lock"

# Bastiones
bastion_instance_type = "t3.micro"
bastion_key_name      = "dev-ssh-key"

# ALB Configuración
alb_name        = "dev-alb"
alb_target_port = 80

# ECS Configuración
ecs_cluster_name   = "dev-cluster"
ecs_service_name   = "dev-service"
ecs_task_family    = "dev-task"
ecs_desired_count  = 2
ecs_container_port = 80
ecs_container_name = "dev-container"

# VPC Configuración
vpc_cidr               = "10.0.0.0/16"
public_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets        = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones     = ["us-east-1a", "us-east-1b"]