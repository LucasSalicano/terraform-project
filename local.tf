resource "local_file" "example" {
    filename = "example.txt"
    content  = var.content
}

data "local_file" "local" {
  filename = "example.txt"
}

output "data-source-result" {
  value = data.local_file.local.content_base64
}

variable "content" {
    type = string
}

output "file-id" {
    value = local_file.example.id
}

output "content" {
    value = var.content
  
}

output "chiken-egg" {
  value = sort(["chicken", "egg"])
}