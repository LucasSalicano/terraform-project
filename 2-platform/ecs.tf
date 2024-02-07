provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
    region = var.region
  }
}

resource "aws_ecs_cluster" "production-fargate-cluster" {
  name = "production-cluster"
}

resource "aws_alb" "ecs_cluster_alb" {
  name            = "${var.ecs_cluster_name}-alb"
  internal        = false
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets         = data.terraform_remote_state.infrastructure.public_subnets

  tags = {
    Name = "${var.ecs_cluster_name}-alb"
  }
}

resource "aws_alb_listener" "ecs_alb_https_listener" {
  load_balancer_arn = aws_alb.ecs_cluster_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ecs_domain_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }

  depends_on = [aws_alb_target_group.ecs_default_target_group]
}

resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${var.ecs_cluster_name}-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.infrastructure.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.ecs_cluster_name}-default-tg"
  }
}
resource "aws_route53_record" "ecs_load_balancer_record" {
  name    = "*.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    name                   = aws_lb.ecs_cluster_alb.dns_name
    zone_id                = aws_lb.ecs_cluster_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_role" "ecs_cluster_role" {
  name = "${var.ecs_cluster_name}-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name = "${var.ecs_cluster_name}-iam-policy"
  role = aws_iam_role.ecs_cluster_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs.*",
          "ec2.*",
          "elasticloadbalancing.*",
          "application-autoscaling.*",
          "ecr.*",
          "cloudwatch.*",
          "dynamodb.*",
          "s3.*",
          "sns.*",
          "sqs.*",
        ],
        Resource = "*"
      }
    ]
  })
}
