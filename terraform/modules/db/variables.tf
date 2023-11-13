variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the privet key used for ssh access"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "db_disk_image" {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}
variable "subnet_id" {
  description = "Subnets for modules"
}
variable "env" {
  description = "Environment stage, prod"
}
