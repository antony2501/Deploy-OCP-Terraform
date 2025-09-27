# Terraform: Tạo Folder Cluster trên Server

Module này tạo folder với tên cluster trong `/home` trên server 192.168.74.130.

## Cách sử dụng:

### 1. Cấu hình biến
```bash
# Copy file example
cp terraform.tfvars.example terraform.tfvars

# Chỉnh sửa terraform.tfvars
cluster_name = "my-cluster-name"  # Thay đổi tên cluster của bạn
```

### 2. Chạy Terraform
```bash
# Initialize
terraform init

# Plan để xem trước
terraform plan

# Apply để tạo folder
terraform apply
```

## Kết quả:
- Folder sẽ được tạo tại: `/home/{cluster_name}`
- Ví dụ: nếu `cluster_name = "ocp-prod"` thì folder sẽ là `/home/ocp-prod`

## Thông tin server:
- **IP**: 192.168.74.130
- **User**: root  
- **Password**: 123
- **SSH Port**: 22

## Ví dụ:
```hcl
# terraform.tfvars
cluster_name = "my-ocp-cluster"
```

Sẽ tạo folder: `/home/my-ocp-cluster`
