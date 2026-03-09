variable "environment" {
  type = string
}

variable "bucket_ids" {
  type = map(string)
}

variable "glue_role_arn" {
  type = string
}
