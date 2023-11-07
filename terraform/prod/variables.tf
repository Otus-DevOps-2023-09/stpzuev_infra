variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  default     = "ru-central1-a"
}
variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}
variable "image_id" {
  description = "Disk image"
}
variable "subnet_id" {
  description = "Subnet"
}
variable "service_account_key_file" {
  description = "key .json"
}
variable "service_account_id" {
  description = "SA id"
}
variable "instances_count" {
  description = "Default count of instances"
  type        = number
  default     = 1
}
variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable "db_disk_image" {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable "bucket_name" {
  description = "Name of S3 bucket"
}
variable "access_key" {
  description = "S3 access key"
}
variable "secret_key" {
  description = "S3 secret key"
}
variable "env" {
  description = "Environment stage, prod"
}
