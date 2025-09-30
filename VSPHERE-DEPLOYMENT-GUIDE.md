# Hướng dẫn Deploy OpenShift trên vSphere với Terraform

## 📋 Thông tin vSphere từ install-config.yaml

Dựa trên thông tin từ `install-config.yaml`, hệ thống sẽ deploy trên:

- **vSphere Server**: `10.0.55.12`
- **Datacenter**: `Amigo`
- **Datastore**: `AMIGO LAB 02`
- **Network**: `PG-VLAN195`
- **Resource Pool**: `/Amigo/host/Amigo/Resources`
- **Folder**: `/Amigo/vm/CPlabs`
- **Template**: `rhel-8-ocp-template` (cần tạo trước)

## 🏗️ Cấu trúc Terraform

```
Deploy-OCP-Terraform/
├── vsphere-config.tf           # vSphere provider & data sources
├── bootstrap-deployment.tf     # Main deployment module
├── variable.tf                 # Root variables
├── terraform.tfvars           # Configuration values
├── install-config.yaml        # OpenShift config
└── bootstrap-node/
    ├── data-sources.tf        # vSphere data sources (module)
    ├── bootstrap-vm.tf        # Bootstrap VM
    ├── bootstrap-wait.tf      # Wait for bootstrap ready
    ├── master-vms.tf          # Master VMs
    ├── worker-vms.tf          # Worker VMs
    ├── variables.tf           # Module variables
    └── outputs.tf             # Module outputs
```

## 🚀 Các bước Deploy

### Bước 1: Chuẩn bị Template VM
```bash
# Tạo template VM từ RHEL 8 OVA trước
# Template name: rhel-8-ocp-template
# Đặt trong folder: /Amigo/vm/templates
```

### Bước 2: Cấu hình terraform.tfvars
```bash
# Đã cập nhật với thông tin từ install-config.yaml
cluster_name = "cp4dddddd"
vsphere_network = "PG-VLAN195"
vsphere_folder = "/Amigo/vm/CPlabs"
ingress_vip = "10.0.95.19"
```

### Bước 3: Tạo Ignition Configs
```bash
# Chạy openshift-install để tạo ignition configs
openshift-install create ignition-configs

# Sau đó cập nhật terraform.tfvars với:
master_ign_base64 = "base64_encoded_master_ignition"
worker_ign_base64 = "base64_encoded_worker_ignition"
bootstrap_ign_sha256 = "sha256_checksum"
```

### Bước 4: Deploy với Terraform

#### Cách 1: Deploy tự động (Khuyến nghị)
```bash
terraform init
terraform plan
terraform apply
```

#### Cách 2: Deploy từng bước
```bash
# Bước 1: Bootstrap VM
terraform apply -target=module.bootstrap_nodes.vsphere_virtual_machine.bootstrap

# Bước 2: Master VMs
terraform apply -target=module.bootstrap_nodes.vsphere_virtual_machine.master

# Bước 3: Worker VMs
terraform apply -target=module.bootstrap_nodes.vsphere_virtual_machine.worker
```

## 📊 VM Configuration

### Bootstrap VM
- **Name**: `{cluster_name}-bootstrap`
- **IP**: `10.0.98.80`
- **CPU**: 4 cores
- **Memory**: 16GB
- **Disk**: 120GB
- **Network**: DHCP từ bastion server

### Master VMs (3 nodes)
- **Names**: `{cluster_name}-master-0`, `{cluster_name}-master-1`, `{cluster_name}-master-2`
- **IPs**: `10.0.98.81`, `10.0.98.82`, `10.0.98.83`
- **CPU**: 4 cores
- **Memory**: 16GB
- **Disk**: 120GB

### Worker VMs (3 nodes)
- **Names**: `{cluster_name}-worker-0`, `{cluster_name}-worker-1`, `{cluster_name}-worker-2`
- **IPs**: `10.0.98.90`, `10.0.98.91`, `10.0.98.92`
- **CPU**: 2 cores
- **Memory**: 8GB
- **Disk**: 120GB

## 🔧 Network Configuration

### Static IP Configuration
Tất cả VMs sử dụng static IP với format:
```
ip=<IP>::<gateway>:<netmask>:<hostname>:<interface>:none nameserver=<dns>
```

- **Gateway**: `10.0.98.1`
- **Netmask**: `255.255.255.0`
- **DNS**: `10.1.102.42`
- **Interface**: `ens192`

## 🎯 VIP Addresses

- **API VIP**: `10.0.98.120`
- **Ingress VIP**: `10.0.95.19`

## 🔍 Monitoring & Verification

### Kiểm tra Bootstrap VM
```bash
# SSH vào bootstrap VM
ssh core@10.0.98.80

# Kiểm tra logs
journalctl -u bootkube.service -f
```

### Kiểm tra Master VMs
```bash
# SSH vào master VMs
ssh core@10.0.98.81
ssh core@10.0.98.82
ssh core@10.0.98.83

# Kiểm tra etcd cluster
etcdctl member list
```

### Kiểm tra Worker VMs
```bash
# SSH vào worker VMs
ssh core@10.0.98.90
ssh core@10.0.98.91
ssh core@10.0.98.92
```

### Kiểm tra Cluster Status
```bash
# Từ master node
oc get nodes
oc get clusteroperators
```

## 🧹 Cleanup

### Xóa Bootstrap VM sau khi cluster hoàn thành
```bash
terraform destroy -target=module.bootstrap_nodes.vsphere_virtual_machine.bootstrap
```

### Xóa toàn bộ cluster
```bash
terraform destroy
```

## ⚠️ Lưu ý quan trọng

1. **Template VM**: Phải tạo template từ RHEL 8 OVA trước khi deploy
2. **Network**: Đảm bảo VLAN 195 đã được cấu hình trên vSphere
3. **Resource Pool**: Kiểm tra resource pool có đủ tài nguyên
4. **DNS**: Đảm bảo DNS server `10.1.102.42` có thể resolve
5. **Bastion**: Đảm bảo bastion server có thể serve ignition files
6. **Dependencies**: Terraform sẽ tự động đảm bảo thứ tự deployment

## 🆘 Troubleshooting

### Lỗi thường gặp:

1. **Template không tìm thấy**: Kiểm tra tên template trong `terraform.tfvars`
2. **Network không tồn tại**: Kiểm tra tên network trên vSphere
3. **Resource pool không đủ**: Kiểm tra tài nguyên trong vSphere
4. **Bootstrap không khởi động**: Kiểm tra ignition URL và network connectivity
