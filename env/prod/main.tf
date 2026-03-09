provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = var.bucket_name
}

module "iam" {
  source        = "../../modules/iam"
  bucket_arn    = module.s3.bucket_arn
  admin_users   = var.admin_users
  analyst_users = var.users
}
