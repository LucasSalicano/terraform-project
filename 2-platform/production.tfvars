# Remote State
remote_state_key = "PROD/platform.tfstate"
remote_state_bucket = "ecs-fargate-terraform-remote-state"

# ECS Cluster
ecs_domain_name = "example.com"
ecs_cluster_name = "ecs-fargate-cluster"
internet_cidr_block = "0.0.0.0/0"
ecs_cluster_security_group_name = "ecs-fargate-cluster-sg"