

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

# Variables cho install-config.yaml
variable "base_domain" {
  description = "Base domain cho OpenShift cluster"
  type        = string
  default     = "cloud.lab"
}

variable "machine_network_cidr" {
  description = "Machine network CIDR"
  type        = string
  default     = "10.128.0.0/14"
}

variable "service_network_cidr" {
  description = "Service network CIDR"
  type        = string
  default     = "172.30.0.0/16"
}

variable "api_vip" {
  description = "API VIP address"
  type        = string
}

variable "ingress_vip" {
  description = "Ingress VIP address"
  type        = string
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
  default     = "10.0.55.12"
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  default     = "administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
  default     = "VMware1!VMware1!"
}

variable "vsphere_network" {
  description = "vSphere network name"
  type        = string
  default     = "PG-VLAN195"
}