output "vpc_id" {
  value = data.terraform_remote_state.infrastructure.vpc_id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.infrastructure.vpc_cidr_block
}

output "ecs_alb_listener_arn" {
  value = module.ecs_alb_listener.arn
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.name
}

output "ecs_cluster_role_name" {
  value = module.ecs_cluster.role_name
}

output "ecs_cluster_role_arn" {
  value = module.ecs_cluster.role_arn
}

output "ecs_domain_name" {
  value = module.ecs_domain.name
}

output "ecs_public_subnets" {
  value = data.terraform_remote_state.infrastructure.public_subnets
}

output "ecs_private_subnets" {
  value = data.terraform_remote_state.infrastructure.private_subnets
}
