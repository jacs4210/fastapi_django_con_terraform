# Variables generales
environment = "prod"
region      = "us-east-1"

# RDS Configuración
rds_instance_class     = "db.t3.medium"
rds_allocated_storage  = 50
rds_engine_version     = "15.4"
rds_master_username    = "prod_admin"
rds_master_password    = "prodpassword456"
rds_backup_retention   = 14
rds_multi_az           = false
rds_public_accessible  = false

# Nuevo usuario de solo lectura
rds_readonly_user      = "readonly_user"
rds_readonly_password  = "readonlypassword123"

# Bucket S3 para estado remoto
terraform_s3_bucket_name = "prod-bucket-terraform"
terraform_dynamodb_table = "prod-terraform-lock"

# Bastiones
bastion_instance_type = "t3.medium"
bastion_key_name      = "prod-ssh-key"

# ALB Configuración
alb_name        = "prod-alb"
alb_target_port = 80

# ECS Configuración
ecs_cluster_name   = "prod-cluster"
ecs_service_name   = "prod-service"
ecs_task_family    = "prod-task"
ecs_desired_count  = 4
ecs_container_port = 80
ecs_container_name = "prod-container"

# VPC Configuración
vpc_cidr               = "10.1.0.0/16"
public_subnets         = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets        = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones     = ["us-east-1a", "us-east-1b"]