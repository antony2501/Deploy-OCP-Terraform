

# Variables cho server và folder creation
variable "cluster_name" {
  description = "Tên cluster - sẽ được dùng để tạo folder"
  type        = string
}

variable "server_host" {
  description = "IP của server"
  type        = string
  default     = "192.168.74.130"
}

variable "server_user" {
  description = "Username để SSH vào server"
  type        = string
  default     = "root"
}

variable "server_password" {
  description = "Password để SSH vào server"
  type        = string
  default     = "123"
}

variable "server_ssh_port" {
  description = "SSH port của server"
  type        = number
  default     = 22
}