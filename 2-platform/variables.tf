variable "region" {
  default = "us-east-1"
}

variable "remote_state_bucket" {
  default = "terraform-remote-state"
}

variable "remote_state_key" {
  default = "infrastructure.tfstate"
}

variable "ecs_cluster_name" {
  default = "production-cluster"
}

variable "internet_cidr_block" {}