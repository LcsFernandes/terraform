############################################
# WORKGROUP FINANCIAL
############################################

resource "aws_athena_workgroup" "financial" {
  name = "wg-financial-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.athena_bucket_name}/financial/"
    }
  }
}

############################################
# WORKGROUP MARKETING
############################################

resource "aws_athena_workgroup" "marketing" {
  name = "wg-marketing-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.athena_bucket_name}/marketing/"
    }
  }
}
