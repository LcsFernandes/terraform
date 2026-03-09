variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "admin_users" {
  type = list(string)
}
variable "users" {
  type = list(string)
}
