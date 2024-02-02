resource "aws_security_group" "ecs_alb_security_group" {
  name        = var.ecs_cluster_name - "alb-sg"
  description = "Secruity group for the ECS cluster ALB"
  vpc_id      = data.terraform_remote_state.infrastructure.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.internet_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet_cidr_block]
  }
}
