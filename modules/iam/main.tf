############################################
# IDENTIDADE DA CONTA
############################################

data "aws_caller_identity" "current" {}

############################################
# USUÁRIOS
############################################

resource "aws_iam_user" "all_users" {
  for_each = toset(concat(var.admin_users, var.financial_users, var.marketing_users))
  name     = each.key
  path     = "/data-team/"
}


############################################
# GRUPOS (APENAS ORGANIZAÇÃO)
############################################

resource "aws_iam_group" "admin" {
  name = "Data-Admin-Group"
}

resource "aws_iam_group" "financial" {
  name = "Data-Financial-Group"
}

resource "aws_iam_group" "marketing" {
  name = "Data-Marketing-Group"
}

resource "aws_iam_group_membership" "admin_members" {
  name  = "admin-membership"
  users = var.admin_users
  group = aws_iam_group.admin.name
}

resource "aws_iam_group_membership" "fin_members" {
  name  = "fin-membership"
  users = var.financial_users
  group = aws_iam_group.financial.name

  depends_on = [aws_iam_user.all_users]
}

resource "aws_iam_group_membership" "mkt_members" {
  name  = "mkt-membership"
  users = var.marketing_users
  group = aws_iam_group.marketing.name

  depends_on = [aws_iam_user.all_users]
}

############################################
# POLICYS FINANCIAL
############################################

resource "aws_iam_group_policy" "financial_policy" {
  name  = "financial-datalake-access"
  group = aws_iam_group.financial.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # Athena
      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:ListWorkGroups",
          "athena:GetWorkGroup"
        ],
        Resource = "*"
      },

      # Glue
      {
        Effect = "Allow",
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions"
        ],
        Resource = "*"
      },

      # Lake Formation (OBRIGATÓRIO)
      {
        Effect = "Allow",
        Action = [
          "lakeformation:GetDataAccess"
        ],
        Resource = "*"
      },

      # Bucket resultado Athena
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = var.athena_bucket_arn
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = "${var.athena_bucket_arn}/*"
      }
    ]
  })
}
############################################
# POLICYS MARKETING
############################################

resource "aws_iam_group_policy" "marketing_policy" {
  name  = "marketing-datalake-access"
  group = aws_iam_group.marketing.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:ListWorkGroups",
          "athena:GetWorkGroup"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "lakeformation:GetDataAccess"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = var.athena_bucket_arn
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = "${var.athena_bucket_arn}/*"
      }
    ]
  })
}

############################################
# POLICYS ADMINISTRATOR
############################################


resource "aws_iam_group_policy" "admin_policy" {
  name  = "admin-full-access"
  group = aws_iam_group.admin.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      }
    ]
  })
}

############################################
# POLICYS GLUE
############################################

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_service_role" {
  name               = "role-glue-service-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

resource "aws_iam_role_policy_attachment" "glue_service_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_lf_access" {
  name = "policy-glue-lakeformation-access"
  role = aws_iam_role.glue_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["lakeformation:GetDataAccess"],
      Resource = "*"
    }]
  })
}




