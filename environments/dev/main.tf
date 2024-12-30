# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================================== CREATE VPC ==============================================================================

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Crear las subredes públicas
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_1_name
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_2_name
  }
}

# Crear las subredes privadas
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az_1

  tags = {
    Name = var.private_subnet_1_name
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az_2

  tags = {
    Name = var.private_subnet_2_name
  }
}

# Crear un grupo de seguridad
resource "aws_security_group" "my_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.sg_ingress_from_port
    to_port     = var.sg_ingress_to_port
    protocol    = "tcp"
    cidr_blocks = var.sg_ingress_cidr_blocks
  }

  tags = {
    Name = var.sg_name
  }
}

# Crear una NACL
resource "aws_network_acl" "my_nacl" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.nacl_name
  }
}

# Crear reglas en la NACL para HTTPS
resource "aws_network_acl_rule" "ingress_https" {
  network_acl_id = aws_network_acl.my_nacl.id
  rule_number    = var.nacl_ingress_rule_number
  egress         = false
  protocol       = "tcp"
  from_port      = var.nacl_https_from_port
  to_port        = var.nacl_https_to_port
  cidr_block     = var.nacl_https_cidr
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "egress_https" {
  network_acl_id = aws_network_acl.my_nacl.id
  rule_number    = var.nacl_egress_rule_number
  egress         = true
  protocol       = "tcp"
  from_port      = var.nacl_https_from_port
  to_port        = var.nacl_https_to_port
  cidr_block     = var.nacl_https_cidr
  rule_action    = "allow"
}

# Crear un Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

# Crear una tabla de ruteo para subredes públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.route_table_name
  }
}

# Asociar las subredes públicas con la tabla de ruteo
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Continuar con el resto de recursos de la infraestructura...

# ============================================================================== DATABASE ==============================================================================

# Crear un grupo de subredes RDS (DB Subnet Group)
resource "aws_db_subnet_group" "my_subnet_group" {
  name        = "${var.environment}-mi-subnet-group"
  description = "Subnet group para la base de datos"
  subnet_ids  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

resource "aws_db_instance" "mi_postgresql" {
  identifier        = var.db_identifier
  instance_class    = var.db_instance_class
  engine            = var.db_engine
  allocated_storage = var.db_allocated_storage
  db_subnet_group_name = aws_db_subnet_group.my_subnet_group.name
  username          = var.db_username
  password          = var.db_password
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  publicly_accessible = var.db_publicly_accessible
  backup_retention_period = var.db_backup_retention_period
  multi_az          = var.db_multi_az
  storage_encrypted = true
  engine_version    = var.db_engine_version
  port              = var.db_port
}

# Crear grupo de seguridad para la instancia RDS en la VPC
resource "aws_security_group" "db_security_group" {
  name        = "${var.environment}-mi-db-security-group"
  description = "Grupo de seguridad para la base de datos"
  vpc_id      = aws_vpc.main.id
}

# Permitir acceso de ECS al grupo de seguridad de la BD
resource "aws_security_group_rule" "db_ingress_rule" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr]
  security_group_id = aws_security_group.db_security_group.id
}

# Crear una instancia bastión en la red pública 1
resource "aws_instance" "bastion_az1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.bastion_instance_type
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.bastion_sg.name]

  tags = {
    Name = "${var.environment}-Bastion-AZ1"
  }
}

# Crear una instancia bastión en la red pública 2
resource "aws_instance" "bastion_az2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.bastion_instance_type
  key_name      = var.bastion_key_name
  subnet_id     = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.bastion_sg.name]

  tags = {
    Name = "${var.environment}-Bastion-AZ2"
  }
}

# Crear Network Load Balancer (NLB)
resource "aws_lb" "bastion_nlb" {
  name               = "${var.environment}-mi-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups   = [aws_security_group.nlb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Crear un target group para los bastiones
resource "aws_lb_target_group" "bastion_targets" {
  name     = "${var.environment}-bastion-targets"
  protocol = "TCP"
  port     = 22
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
}

# Registrar las instancias bastión en el target group
resource "aws_lb_target_group_attachment" "bastion_az1_attachment" {
  target_group_arn = aws_lb_target_group.bastion_targets.arn
  target_id        = aws_instance.bastion_az1.id
}

resource "aws_lb_target_group_attachment" "bastion_az2_attachment" {
  target_group_arn = aws_lb_target_group.bastion_targets.arn
  target_id        = aws_instance.bastion_az2.id
}

# Crear listener para el NLB en el puerto 22
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.bastion_nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion_targets.arn
  }
}

# Crear grupo de seguridad para el NLB
resource "aws_security_group" "nlb_sg" {
  name        = "${var.environment}-nlb-security-group"
  description = "Grupo de seguridad para el Network Load Balancer"
  vpc_id      = aws_vpc.main.id
}

# Permitir tráfico desde cualquier IP al NLB en el puerto 22
resource "aws_security_group_rule" "nlb_ingress_rule" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nlb_sg.id
}

# Crear grupo de seguridad para los bastiones
resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-sg-bastion"
  description = "Grupo de seguridad para los bastiones"
  vpc_id      = aws_vpc.main.id
}

# Permitir tráfico SSH desde el NLB hacia los bastiones
resource "aws_security_group_rule" "bastion_ingress_rule" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  source_security_group_id = aws_security_group.nlb_sg.id
}

# Permitir salida hacia RDS desde bastiones
resource "aws_security_group_rule" "bastion_egress_rule" {
  type        = "egress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  cidr_blocks = [var.vpc_cidr]
}

# Permitir tráfico desde los bastiones hacia RDS
resource "aws_security_group_rule" "db_ingress_from_bastion" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_group_id = aws_security_group.db_security_group.id
  source_security_group_id = aws_security_group.bastion_sg.id
}

# ============================================================================== CONF STATE TERRAFORM ==============================================================================

# Crear un bucket de S3 para almacenar el estado de Terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_s3_bucket_name
  region = var.region
}

# Crear una tabla en DynamoDB con LOCKID como clave primaria
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.terraform_dynamodb_table
  hash_key       = "LOCKID"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "LOCKID"
    type = "S"
  }
}

# Crear la política usando el archivo policy.json
resource "aws_iam_policy" "terraform_state_policy" {
  name        = "${var.environment}-policy-terraform-state"
  description = "Política de acceso a Terraform State"
  policy      = file("policy.json")
}

terraform {
  backend "s3" {
    bucket         = var.terraform_s3_bucket_name   # Nombre del bucket S3
    key            = "ruta/terraform.tfstate"       # Ruta en el bucket para almacenar el estado
    region         = var.region                     # Región del bucket S3
    dynamodb_table = var.terraform_dynamodb_table  # Nombre de la tabla de DynamoDB para el bloqueo
    encrypt        = true                           # Habilita el cifrado del estado
  }
}