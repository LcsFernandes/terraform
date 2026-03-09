output "bucket_id" {
  description = "O nome/ID do bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "O ARN do bucket (usado em permissões IAM)"
  value       = aws_s3_bucket.this.arn
}