output "database_names" {
  value = { for k, v in aws_glue_catalog_database.db : k => v.name }
}

output "lakeformation_resources" {
  value = aws_lakeformation_resource.buckets
}