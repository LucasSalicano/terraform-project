variable "region" {
  default = "us-east-1"
}

variable "remote_state_bucket" {
  default = "terraform-remote-state"
}

variable "remote_state_key" {
  default = "infrastructure.tfstate"
}
