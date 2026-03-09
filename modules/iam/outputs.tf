# output "lakeformation_admin_role_arn" {
#   value = aws_iam_role.lakeformation_admin_role.arn
# }

# output "financial_role_arn" {
#   value = aws_iam_role.financial_role.arn
# }

# output "marketing_role_arn" {
#   value = aws_iam_role.marketing_role.arn
# }

output "glue_role_arn" {
  value = aws_iam_role.glue_service_role.arn
}

