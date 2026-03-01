// AWS Terraform module skeleton
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

// Example: VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "example-vpc"
  }
}

// Example: ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "example-cluster"
}

// Example: RDS Postgres (minimal, for illustration)
resource "aws_db_subnet_group" "default" {
  name       = "example-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = var.db_instance_class
  identifier           = var.db_identifier
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot  = true
}

// IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-${var.db_identifier}"
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// CloudWatch log groups for services
resource "aws_cloudwatch_log_group" "python" {
  name              = "/ecs/python-service"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "node" {
  name              = "/ecs/node-service"
  retention_in_days = 7
}

// Security group for ECS tasks and ALB
resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg-${var.db_identifier}"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Application Load Balancer
resource "aws_lb" "app" {
  name               = "example-alb-${var.db_identifier}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.ecs_sg.id]
}

resource "aws_lb_target_group" "python_tg" {
  name     = "python-tg-${var.db_identifier}"
  port     = var.python_container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "node_tg" {
  name     = "node-tg-${var.db_identifier}"
  port     = var.node_container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_tg.arn
  }
}

// Listener rules for path-based routing
resource "aws_lb_listener_rule" "python_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.python_tg.arn
  }

  condition {
    path_pattern {
      values = ["/python/*", "/python"]
    }
  }
}

resource "aws_lb_listener_rule" "node_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.node_tg.arn
  }

  condition {
    path_pattern {
      values = ["/node/*", "/node"]
    }
  }
}

// ECS Task Definitions
resource "aws_ecs_task_definition" "python" {
  family                   = "python-task-${var.db_identifier}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "python"
      image     = var.python_image
      essential = true
      portMappings = [
        {
          containerPort = var.python_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.python.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "python"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "node" {
  family                   = "node-task-${var.db_identifier}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "node"
      image     = var.node_image
      essential = true
      portMappings = [
        {
          containerPort = var.node_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.node.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "node"
        }
      }
    }
  ])
}

// ECS Services
resource "aws_ecs_service" "python" {
  name            = "python-service-${var.db_identifier}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.python.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.python_tg.arn
    container_name   = "python"
    container_port   = var.python_container_port
  }

  depends_on = [aws_lb_listener.front_end]
}

resource "aws_ecs_service" "node" {
  name            = "node-service-${var.db_identifier}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.node.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.node_tg.arn
    container_name   = "node"
    container_port   = var.node_container_port
  }

  depends_on = [aws_lb_listener.front_end]
}
