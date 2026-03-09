############################################
# LOCALS
############################################

locals {
  datalake_buckets = {
    financial_bronze = var.bucket_name_financial_bronze
    financial_silver = var.bucket_name_financial_silver
    financial_gold   = var.bucket_name_financial_gold
    marketing_bronze = var.bucket_name_marketing_bronze
    marketing_silver = var.bucket_name_marketing_silver
    marketing_gold   = var.bucket_name_marketing_gold
    athena_results   = var.bucket_name_athena_results
  }
}

############################################
# 1. BUCKETS S3 (CAMADAS)
############################################

module "s3_buckets" {
  source      = "../../modules/s3"
  for_each    = local.datalake_buckets
  bucket_name = each.value
  environment = var.environment
}

############################################
# 2. IAM (USUÁRIOS E ROLES)
############################################

module "iam" {
  source = "../../modules/iam"

  athena_bucket_arn = module.s3_buckets["athena_results"].bucket_arn
  environment       = var.environment
  admin_users       = var.admin_users
  financial_users   = var.financial_users
  marketing_users   = var.marketing_users
}

############################################
# IDENTIDADE ATUAL (SEU USUÁRIO)
############################################

data "aws_caller_identity" "current" {}

############################################
# 3. LAKE FORMATION
############################################

module "lake_formation" {
  source      = "../../modules/lake_formation"
  environment = var.environment

  lakeformation_admins = [
    data.aws_caller_identity.current.arn, "arn:aws:iam::953082827325:root"
  ]

  account_id = data.aws_caller_identity.current.account_id

  financial_users = var.financial_users
  marketing_users = var.marketing_users

  bucket_arns = {
    for k, v in module.s3_buckets :
    k => v.bucket_arn
    if k != "athena_results"
  }

  glue_role_arn = module.iam.glue_role_arn
}


############################################
# 4. GLUE (ETL / CRAWLER)
############################################

module "glue" {
  source      = "../../modules/glue"
  environment = var.environment

  bucket_ids = {
    for k, v in module.s3_buckets :
    k => v.bucket_id
    if k != "athena_results"
  }

  glue_role_arn = module.iam.glue_role_arn

  depends_on = [module.lake_formation]
}

############################################
# 5. ATHENA
############################################

module "athena" {
  source = "../../modules/athena"

  environment        = var.environment
  athena_bucket_name = module.s3_buckets["athena_results"].bucket_id

  depends_on = [module.s3_buckets]
}
