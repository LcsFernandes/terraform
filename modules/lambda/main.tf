# # 1. Compacta o código Python automaticamente
# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_file = "${path.module}/../../scripts/lambda_function.py"
#   output_path = "${path.module}/lambda_function_payload.zip"
# }

# # 2. Role IAM para a Lambda (A identidade da função)
# resource "aws_iam_role" "lambda_role" {
#   name = "role-${var.function_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }

# # 3. Permissão para a Lambda ler o S3 e escrever Logs no CloudWatch
# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "policy-${var.function_name}"
#   role = aws_iam_role.lambda_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action   = ["s3:GetObject", "s3:ListBucket"]
#         Effect   = "Allow"
#         Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
#       },
#       {
#         Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
#         Effect   = "Allow"
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# # 4. A Função Lambda
# resource "aws_lambda_function" "this" {
#   filename         = data.archive_file.lambda_zip.output_path
#   function_name    = var.function_name
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "lambda_function.lambda_handler"
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
#   runtime          = "python3.9"

#   environment {
#     variables = {
#       BUCKET_NAME = var.bucket_id
#       ENV         = var.environment
#     }
#   }
# }