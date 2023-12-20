terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "db" {
  name        = "reddit-db-${var.env}"
  platform_id = "standard-v3"

  labels = {
    tags = "reddit-db-${var.env}"
  }

  resources {
    core_fraction = 50
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.db_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
  }

 metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
