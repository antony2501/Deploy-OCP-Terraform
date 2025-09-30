# ====== VSPHERE PROVIDER CONFIGURATION ======
# Cấu hình vSphere provider dựa trên thông tin từ install-config.yaml

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# vSphere Provider Configuration
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true  # Chỉ dùng trong môi trường lab/testing
}

# ====== VSPHERE DATA SOURCES ======
# Data sources để lookup thông tin vSphere infrastructure

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter_name
}

data "vsphere_datastore" "ds" {
  name          = var.vsphere_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "rp" {
  name          = var.vsphere_resource_pool_path
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Template VM (cần tạo template từ OVA trước)
data "vsphere_virtual_machine" "template" {
  name          = var.template_vm_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ====== OUTPUTS ======
# Output các thông tin quan trọng để sử dụng trong các module khác

output "vsphere_datacenter_id" {
  description = "ID của vSphere datacenter"
  value       = data.vsphere_datacenter.dc.id
}

output "vsphere_datastore_id" {
  description = "ID của vSphere datastore"
  value       = data.vsphere_datastore.ds.id
}

output "vsphere_network_id" {
  description = "ID của vSphere network"
  value       = data.vsphere_network.net.id
}

output "vsphere_resource_pool_id" {
  description = "ID của vSphere resource pool"
  value       = data.vsphere_resource_pool.rp.id
}

output "vsphere_template_id" {
  description = "ID của vSphere template VM"
  value       = data.vsphere_virtual_machine.template.id
}

# ====== VSPHERE INFRASTRUCTURE SUMMARY ======
output "vsphere_infrastructure_summary" {
  description = "Tóm tắt thông tin vSphere infrastructure"
  value = {
    server           = var.vsphere_server
    datacenter       = var.vsphere_datacenter_name
    datastore        = var.vsphere_datastore_name
    network          = var.vsphere_network
    resource_pool    = var.vsphere_resource_pool_path
    folder           = var.vsphere_folder
    template         = var.template_vm_name
  }
}
