variable "aws_region" {
  type = string
}
variable "environment" {
  type = string
}
variable "bucket_name_financial_bronze" {
  type = string
}
variable "bucket_name_financial_silver" {
  type = string
}
variable "bucket_name_financial_gold" {
  type = string
}
variable "bucket_name_marketing_bronze" {
  type = string
}
variable "bucket_name_marketing_silver" {
  type = string
}
variable "bucket_name_marketing_gold" {
  type = string
}
variable "admin_users" {
  type = list(string)
}
variable "financial_users" {
  type = list(string)
}
variable "marketing_users" {
  type = list(string)
}
variable "bucket_name_athena_results" {
  type = string
}

