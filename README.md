# Terraform: Tạo Folder Cluster và Copy install-config.yaml

Module này tạo folder với tên cluster trong `/home` và copy file `install-config.yaml` với template variables trên server 192.168.74.130.

## Chức năng:
1. ✅ Tạo folder `/home/{cluster_name}`
2. ✅ Copy file `install-config.yaml` với template variables
3. ✅ Thay thế các biến template trong file config

## Cách sử dụng:

### 1. Cấu hình biến
```bash
# Copy file example
cp terraform.tfvars.example terraform.tfvars

# Chỉnh sửa terraform.tfvars với thông tin của bạn
```

### 2. Chạy Terraform
```bash
# Initialize
terraform init

# Plan để xem trước
terraform plan

# Apply để tạo folder và copy file
terraform apply
```

## Kết quả:
- Folder được tạo tại: `/home/{cluster_name}`
- File `install-config.yaml` được copy vào: `/home/{cluster_name}/install-config.yaml`
- Các biến template được thay thế với giá trị thực

## Thông tin server:
- **IP**: 192.168.74.130
- **User**: root  
- **Password**: 123
- **SSH Port**: 22

## Ví dụ cấu hình:
```hcl
# terraform.tfvars
cluster_name = "my-ocp-cluster"
base_domain = "example.com"
api_vip = "10.0.95.18"
ingress_vip = "10.0.95.19"
vsphere_server = "vcenter.example.com"
vsphere_user = "administrator@vsphere.local"
vsphere_password = "your-password"
vsphere_network = "VM Network"
```

## Output:
- `cluster_folder_path`: `/home/my-ocp-cluster`
- `install_config_path`: `/home/my-ocp-cluster/install-config.yaml`
