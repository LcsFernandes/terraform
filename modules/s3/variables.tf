variable "bucket_name" {
  description = "Nome único do bucket S3"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc)"
  type        = string
  default     = "dev"
}