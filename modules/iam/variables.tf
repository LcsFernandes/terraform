variable "environment" {
  type        = string
  description = "Ambiente (dev, prod, etc)"
}

variable "admin_users" {
  type        = list(string)
  description = "Lista de usuários com acesso total"
}

variable "financial_users" {
  type        = list(string)
  description = "Usuários do domínio Financeiro"
}

variable "marketing_users" {
  type        = list(string)
  description = "Usuários do domínio Marketing"
}

variable "athena_bucket_arn" {
  type = string
}
