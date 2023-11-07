variable "cloud_id" {
  description = "Cloud ID"
  #sensitive   = true
}
variable "folder_id" {
  description = "Folder ID"
  #sensitive   = true
}
variable "service_account_key_file" {
  description = "Service account key file"
  sensitive   = true
}
variable "zone" {
  description = "Zone"
  default = "ru-central1-a"
}
variable "bucket_name" {
  description = "Name of S3 bucket"
}
variable "name" {
  description = "SA User Name"
}
