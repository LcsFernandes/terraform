############################################
# GLUE CRAWLERS (BRONZE, SILVER, GOLD)
############################################

resource "aws_glue_crawler" "crawler" {
  for_each = var.bucket_ids

  name          = "crawler-${each.key}-${var.environment}"
  database_name = "db_${each.key}_${var.environment}"
  role          = var.glue_role_arn

  s3_target {
    path = "s3://${each.value}/"
  }

  lake_formation_configuration {
    use_lake_formation_credentials = true
  }
}
