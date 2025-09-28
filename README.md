# Terraform: Tự động cài đặt OpenShift Cluster trên vSphere

Module này tự động hóa toàn bộ quá trình cài đặt OpenShift cluster trên vSphere, bao gồm:

## Chức năng:
1. ✅ Tạo folder `/home/{cluster_name}`
2. ✅ Copy file `install-config.yaml` với template variables
3. ✅ Download OpenShift installer
4. ✅ Generate manifests và ignition files
5. ✅ Tạo VMs trên vSphere (Bootstrap, Control Plane, Worker)
6. ✅ Bootstrap cluster
7. ✅ Hoàn thành cài đặt cluster

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
- File `install-config.yaml` được copy với template variables
- OpenShift installer được download
- Manifests và ignition files được generate
- VMs được tạo trên vSphere:
  - 1 Bootstrap VM
  - 3 Control Plane VMs  
  - 3 Worker VMs (có thể tùy chỉnh)
- Cluster được bootstrap và hoàn thành cài đặt

## Thông tin server:
- **IP**: 192.168.74.130
- **User**: root  
- **Password**: 123
- **SSH Port**: 22

## Ví dụ cấu hình:
```hcl
# terraform.tfvars
cluster_name = "my-ocp-cluster"
base_domain = "cloud.lab"
api_vip = "10.0.95.18"
ingress_vip = "10.0.95.19"
vsphere_server = "10.0.55.12"
vsphere_user = "administrator@vsphere.local"
vsphere_password = "VMware1!VMware1!"
vsphere_network = "PG-VLAN195"
openshift_version = "4.15.0"
worker_count = 3

# CẦN ĐIỀN THÔNG TIN THỰC TỪ vSPHERE
datacenter_id = "datacenter-123"
resource_pool_id = "resgroup-456"
datastore_id = "datastore-789"
host_system_id = "host-101"
network_id = "dvportgroup-202"
ova_name = "rhel-coreos-4.15"
```

## Output:
- `cluster_folder_path`: `/home/my-ocp-cluster`
- `install_config_path`: `/home/my-ocp-cluster/install-config.yaml`
- `cluster_console_url`: `https://console-openshift-console.apps.my-ocp-cluster.cloud.lab`
- `cluster_api_url`: `https://api.my-ocp-cluster.cloud.lab:6443`
- `kubeconfig_path`: `/home/my-ocp-cluster/auth/kubeconfig`

## Lưu ý quan trọng:
1. **Cần có OVA template** cho OpenShift CoreOS
2. **Cần thông tin vSphere IDs** (datacenter, resource pool, datastore, etc.)
3. **Quá trình cài đặt mất 45-60 phút**
4. **Bootstrap VM sẽ tự động bị xóa** sau khi hoàn thành
