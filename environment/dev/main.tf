module "dev_vpc" {
  source = "../../modules/vpc"
}



module "web_server" {
  source            = "../../modules/ec2"
  availability_zone = module.dev_vpc.availability_zones[0]
  subnet_id         = module.dev_vpc.public_subnet_id
  security_groups   = [module.ec2_public_security_group.security_group_id]
}


# ===== Security Group for public EC2 instance =============================================================
module "ec2_public_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 5.0"

  name        = "${var.env_name}-public-ec2-sg"
  description = "Security group for public EC2 instances"
  vpc_id      = module.dev_vpc.vpc_id

  # Allow HTTP and HTTPS from anywhere (public facing)
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Allow SSH only from your IP or a trusted CIDR
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
      cidr_blocks = var.vpc_cidr # replace with your IP
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"] # allow all outbound

  tags = {
    Name = "${var.env_name}-public-ec2-sg"
  }
}





module "app_server" {
  source            = "../../modules/ec2"
  availability_zone = module.dev_vpc.availability_zones[0]
  subnet_id         = module.dev_vpc.private_app_subnet_ids
  security_groups   = [module.ec2_private_security_group.security_group_id]
}


# ===== Security Group for private EC2 instance ===============================================

module "ec2_private_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 5.0"

  name        = "${var.env_name}-private-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = module.dev_vpc.vpc_id
  # Only allow HTTP traffic from the web security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "HTTP from web server only"
      source_security_group_id = module.ec2_public_security_group.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "HTTPS from web server only"
      source_security_group_id = module.ec2_public_security_group.security_group_id
    }
  ]

  # SSH from within VPC only
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from VPC only"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "${var.env_name}-private-ec2-sg"
  }
}



module "dev_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.env_name}-postgresql"

  # Engine
  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.micro"

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  # Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Network — same AZ as your EC2 instances
  # db_subnet_group_name   = "${var.env_name}-db-subnet-group"
  db_subnet_group_name   = module.dev_vpc.db_subnet_group_name
  vpc_security_group_ids = [module.rds_postgresql_security_group.security_group_id]
  availability_zone      = module.dev_vpc.availability_zones[0] # same AZ as EC2s
  multi_az               = false

  # Backups
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Other settings
  deletion_protection      = false # set to true for production
  skip_final_snapshot      = true  # set to false for production
  delete_automated_backups = true

  tags = {
    Name = "${var.env_name}-postgresql"
  }
}





# ===== Security Group for RDS instance ===============================================




module "rds_postgresql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 5.0"

  name        = "${var.env_name}-rds-postgresql-sg"
  description = "Security group for RDS PostgreSQL - allows traffic from private EC2 only"
  vpc_id      = module.dev_vpc.vpc_id

  ingress_rules       = [] # ← add this to disable default rules
  ingress_cidr_blocks = [] # ← add this to clear any default CIDRs

  # ✅ Only allow PostgreSQL (5432) from the private EC2 security group
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from private EC2 only"
      source_security_group_id = module.ec2_private_security_group.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "${var.env_name}-rds-postgresql-sg"
  }
}
