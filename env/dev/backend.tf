terraform {
  backend "s3" {
    bucket         = "terraform-state-central-enviroments"
    key            = "projetos/dados/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}