output "internal_ip_address_db" {
  value = yandex_compute_instance.db.*.network_interface.0.ip_address
}
