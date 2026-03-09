variable "environment" {
  type = string
}

variable "lakeformation_admins" {
  type = list(string)
}

variable "bucket_arns" {
  type = map(string)
}

variable "account_id" {
  type = string
}

variable "financial_users" {
  type = list(string)
}

variable "marketing_users" {
  type = list(string)
}

variable "glue_role_arn" {
  type = string
}