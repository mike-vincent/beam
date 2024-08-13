# VPC Configuration
resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

resource "aws_subnet" "ecs_public" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.AWS_DEFAULT_REGION}a"
  map_public_ip_on_launch = true

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

resource "aws_route_table" "ecs_public" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

resource "aws_route_table_association" "ecs_public" {
  subnet_id      = aws_subnet.ecs_public.id
  route_table_id = aws_route_table.ecs_public.id
}

# Security Groups
resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.PROJECT_NAME}-ecs-sg"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_security_group" "redis_sg" {
  name_prefix = "${var.PROJECT_NAME}-redis-sg"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

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

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.PROJECT_NAME}-cluster"

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "${var.PROJECT_NAME}-redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "redis"
      image = "redis:alpine"
      portMappings = [
        {
          containerPort = 6379
          hostPort      = 6379
        }
      ]
    }
  ])

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Web App Task Definition
resource "aws_ecs_task_definition" "web_app" {
  family                   = "${var.PROJECT_NAME}-web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "web-app"
      image = "beamdental/sre-kata-app"
      portMappings = [
        {
          containerPort = 4567
          hostPort      = 4567
        }
      ]
      environment = [
        {
          name  = "REDIS_URL"
          value = "redis://localhost:6379"
        }
      ]
    }
  ])

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Combined Service (Redis + Web App)
resource "aws_ecs_service" "combined" {
  name            = "${var.PROJECT_NAME}-combined"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web_app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.ecs_public.id]
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.redis_sg.id]
    assign_public_ip = true
  }

  tags = {
    Owner = var.PROJECT_AUTHOR
  }
}

# Output the public IP of the ECS task
output "ecs_task_public_ip" {
  value       = aws_ecs_service.combined.network_configuration[0].assign_public_ip
  description = "The public IP of the ECS task"
}