# Create a new VPC
resource "aws_vpc" "rds_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create two private subnets for RDS in different AZs
resource "aws_subnet" "rds_private_1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.AWS_DEFAULT_REGION}a"

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

resource "aws_subnet" "rds_private_2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.AWS_DEFAULT_REGION}b"

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "rds_igw" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create route table for public subnet
resource "aws_route_table" "rds_public" {
  vpc_id = aws_vpc.rds_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rds_igw.id
  }

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.PROJECT_NAME}-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_private_1.id, aws_subnet.rds_private_2.id]

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create a security group for the EC2 instances in the public subnet
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.PROJECT_NAME}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.rds_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name_prefix = "${var.PROJECT_NAME}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.rds_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Create the RDS instance
resource "aws_db_instance" "default" {
  identifier        = "${var.PROJECT_NAME}-db"
  engine            = "postgres"
  engine_version    = "13"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "mydb"
  username = var.DB_USERNAME
  password = var.DB_PASSWORD

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  backup_retention_period = 0
  skip_final_snapshot     = true
  multi_az                = false
  publicly_accessible     = false

  performance_insights_enabled = false
  storage_encrypted           = false

  maintenance_window = "Sun:03:00-Sun:04:00"

  deletion_protection = false

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

variable "DB_USERNAME" {
  description = "DB username"
  type        = string
}

variable "DB_PASSWORD" {
  description = "DB password"
  type        = string
  sensitive   = true
}

# Output the RDS instance endpoint
output "rds_endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "The connection endpoint for the RDS instance"
}

# Output the RDS instance port
output "rds_port" {
  value       = aws_db_instance.default.port
  description = "The port the RDS instance is listening on"
}