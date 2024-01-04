resource "local_file" "example" {
    filename = "example.txt"
    content  = var.content
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