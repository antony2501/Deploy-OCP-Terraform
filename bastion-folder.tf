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

# Output thông tin folder đã tạo
output "cluster_folder_path" {
  description = "Đường dẫn folder cluster đã tạo"
  value       = "/home/${var.cluster_name}"
}

output "server_info" {
  description = "Thông tin server"
  value = {
    host = var.server_host
    user = var.server_user
    folder_created = "/home/${var.cluster_name}"
  }
}

