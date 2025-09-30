# ====== WAIT FOR BOOTSTRAP VM TO BE READY ======
# Đợi bootstrap VM khởi động và sẵn sàng trước khi tạo master/worker VMs
resource "time_sleep" "wait_for_bootstrap" {
  depends_on = [vsphere_virtual_machine.bootstrap]
  
  # Đợi 2 phút để bootstrap VM khởi động hoàn toàn
  create_duration = "2m"
  
  # Không cần destroy delay
  destroy_duration = "0s"
}
