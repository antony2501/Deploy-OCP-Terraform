# Tạo folder cluster trên server sử dụng null_resource
resource "null_resource" "create_cluster_folder" {
  # Kích hoạt khi có thay đổi cluster_name
  triggers = {
    cluster_name = var.cluster_name
  }

  # Thực thi lệnh tạo folder qua SSH
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.cluster_name}",
      "chmod 755 /home/${var.cluster_name}",
      "echo 'Folder ${var.cluster_name} created successfully'"
    ]
  }

  # Kết nối SSH đến server
  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Copy file install-config.yaml với template variables
resource "null_resource" "copy_install_config" {
  depends_on = [null_resource.create_cluster_folder]
  
  triggers = {
    cluster_name = var.cluster_name
    config_hash = md5(templatefile("${path.module}/install-config.yaml", {
      cluster_name         = var.cluster_name
      base_domain         = var.base_domain
      machine_network_cidr = var.machine_network_cidr
      service_network_cidr = var.service_network_cidr
      api_vip             = var.api_vip
      ingress_vip         = var.ingress_vip
      vsphere_server      = var.vsphere_server
      vsphere_user        = var.vsphere_user
      vsphere_password    = var.vsphere_password
      vsphere_network     = var.vsphere_network
    }))
  }

  # Tạo file install-config.yaml với template
  provisioner "remote-exec" {
    inline = [
      "cat > /home/${var.cluster_name}/install-config.yaml << 'EOF'",
      templatefile("${path.module}/install-config.yaml", {
        cluster_name         = var.cluster_name
        base_domain         = var.base_domain
        machine_network_cidr = var.machine_network_cidr
        service_network_cidr = var.service_network_cidr
        api_vip             = var.api_vip
        ingress_vip         = var.ingress_vip
        vsphere_server      = var.vsphere_server
        vsphere_user        = var.vsphere_user
        vsphere_password    = var.vsphere_password
        vsphere_network     = var.vsphere_network
      }),
      "EOF",
      "chmod 644 /home/${var.cluster_name}/install-config.yaml",
      "echo 'install-config.yaml created successfully in /home/${var.cluster_name}/'"
    ]
  }

  connection {
    type     = "ssh"
    host     = var.server_host
    user     = var.server_user
    password = var.server_password
    port     = var.server_ssh_port
  }
}

# Output thông tin folder đã tạo
output "cluster_folder_path" {
  description = "Đường dẫn folder cluster đã tạo"
  value       = "/home/${var.cluster_name}"
}

output "install_config_path" {
  description = "Đường dẫn file install-config.yaml"
  value       = "/home/${var.cluster_name}/install-config.yaml"
}

output "server_info" {
  description = "Thông tin server"
  value = {
    host = var.server_host
    user = var.server_user
    folder_created = "/home/${var.cluster_name}"
    install_config = "/home/${var.cluster_name}/install-config.yaml"
  }
}

