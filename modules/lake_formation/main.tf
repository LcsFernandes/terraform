
############################
# 1. DATA LAKE SETTINGS
############################

resource "aws_lakeformation_data_lake_settings" "settings" {
  admins = var.lakeformation_admins

  create_database_default_permissions {
    permissions = []
    principal   = "IAM_ALLOWED_PRINCIPALS"
  }

  create_table_default_permissions {
    permissions = []
    principal   = "IAM_ALLOWED_PRINCIPALS"
  }
}

############################
# 2. REGISTRO DOS BUCKETS
############################

resource "aws_lakeformation_resource" "buckets" {
  for_each = var.bucket_arns
  arn      = each.value

  depends_on = [
    aws_lakeformation_data_lake_settings.settings
  ]
}

############################
# 3. DATABASES GLUE
############################


resource "aws_glue_catalog_database" "db" {
  for_each = var.bucket_arns
  name     = "db_${each.key}_${var.environment}"

  depends_on = [
    aws_lakeformation_data_lake_settings.settings
  ]
}

############################
# 4. ADMIN (QUEM RODA O TERRAFORM)
############################

resource "aws_lakeformation_permissions" "admin_catalog" {
  principal        = var.lakeformation_admins[0]
  permissions      = ["ALL"]
  catalog_resource = true

  depends_on = [
    aws_lakeformation_data_lake_settings.settings
  ]
}

resource "aws_lakeformation_permissions" "admin_db" {
  for_each  = aws_glue_catalog_database.db
  principal = var.lakeformation_admins[0]

  database {
    name = each.value.name
  }

  permissions = [
    "DESCRIBE",
    "CREATE_TABLE",
    "ALTER",
    "DROP"
  ]

  depends_on = [
    aws_lakeformation_permissions.admin_catalog
  ]
}


resource "aws_lakeformation_permissions" "admin_tables" {
  for_each  = aws_glue_catalog_database.db
  principal = var.lakeformation_admins[0]

  table {
    database_name = each.value.name
    wildcard      = true
  }

  permissions = [
    "DESCRIBE",
    "SELECT",
    "INSERT",
    "DELETE",
    "ALTER",
    "DROP"
  ]

  depends_on = [
    aws_lakeformation_permissions.admin_catalog
  ]
}

############################
# 5. GLUE (ETL)
############################

resource "aws_lakeformation_permissions" "glue_db" {
  for_each  = aws_glue_catalog_database.db
  principal = var.glue_role_arn

  database {
    name = each.value.name
  }

  permissions = [
    "DESCRIBE",
    "CREATE_TABLE",
    "ALTER",
    "DROP"
  ]
}

resource "aws_lakeformation_permissions" "glue_tables" {
  for_each  = aws_glue_catalog_database.db
  principal = var.glue_role_arn

  table {
    database_name = each.value.name
    wildcard      = true
  }

  permissions = [
    "SELECT",
    "INSERT",
    "DELETE",
    "ALTER"
  ]
}

############################
# 6. FINANCIAL (FULL ACCESS)
############################

resource "aws_lakeformation_permissions" "financial_db" {
  for_each = {
    for pair in flatten([
      for user in var.financial_users : [
        for k, v in aws_glue_catalog_database.db :
        {
          user = user
          db   = v.name
        }
        if strcontains(k, "financial")
      ]
    ]) :
    "${pair.user}-${pair.db}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  database {
    name = each.value.db
  }

  permissions = [
    "DESCRIBE",
    "CREATE_TABLE",
    "ALTER",
    "DROP"
  ]
}

resource "aws_lakeformation_permissions" "financial_tables" {
  for_each = {
    for pair in flatten([
      for user in var.financial_users : [
        for k, v in aws_glue_catalog_database.db :
        {
          user = user
          db   = v.name
        }
        if strcontains(k, "financial")
      ]
    ]) :
    "${pair.user}-${pair.db}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  table {
    database_name = each.value.db
    wildcard      = true
  }

  permissions = [
    "DESCRIBE",
    "SELECT",
    "INSERT",
    "DELETE",
    "ALTER"
  ]
}

############################
# 7. MARKETING (READ ONLY)
############################

resource "aws_lakeformation_permissions" "marketing_db" {
  for_each = {
    for pair in flatten([
      for user in var.marketing_users : [
        for k, v in aws_glue_catalog_database.db :
        {
          user = user
          db   = v.name
        }
        if strcontains(k, "marketing")
      ]
    ]) :
    "${pair.user}-${pair.db}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  database {
    name = each.value.db
  }

  permissions = [
    "DESCRIBE",
    "CREATE_TABLE",
    "ALTER",
    "DROP"
  ]
}

resource "aws_lakeformation_permissions" "marketing_tables" {
  for_each = {
    for pair in flatten([
      for user in var.marketing_users : [
        for k, v in aws_glue_catalog_database.db :
        {
          user = user
          db   = v.name
        }
        if strcontains(k, "marketing")
      ]
    ]) :
    "${pair.user}-${pair.db}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  table {
    database_name = each.value.db
    wildcard      = true
  }

  permissions = [
    "DESCRIBE",
    "SELECT",
    "INSERT",
    "DELETE",
    "ALTER"
  ]
}

############################
# 8. DATA LOCATION (OBRIGATÓRIO)
############################

resource "aws_lakeformation_permissions" "glue_location" {
  for_each  = var.bucket_arns
  principal = var.glue_role_arn

  data_location {
    arn = each.value
  }

  permissions = ["DATA_LOCATION_ACCESS"]

  depends_on = [
    aws_lakeformation_resource.buckets
  ]
}

resource "aws_lakeformation_permissions" "financial_location" {
  for_each = {
    for pair in flatten([
      for user in var.financial_users : [
        for bucket_key, bucket_arn in var.bucket_arns :
        {
          user       = user
          bucket_key = bucket_key
          bucket_arn = bucket_arn
        }
        if strcontains(bucket_key, "financial")
      ]
    ]) :
    "${pair.user}-${pair.bucket_key}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  data_location {
    arn = each.value.bucket_arn
  }

  permissions = ["DATA_LOCATION_ACCESS"]

  depends_on = [
    aws_lakeformation_resource.buckets
  ]
}


resource "aws_lakeformation_permissions" "marketing_location" {
  for_each = {
    for pair in flatten([
      for user in var.marketing_users : [
        for bucket_key, bucket_arn in var.bucket_arns :
        {
          user       = user
          bucket_key = bucket_key
          bucket_arn = bucket_arn
        }
        if strcontains(bucket_key, "marketing")
      ]
    ]) :
    "${pair.user}-${pair.bucket_key}" => pair
  }

  principal = "arn:aws:iam::${var.account_id}:user/data-team/${each.value.user}"

  data_location {
    arn = each.value.bucket_arn
  }

  permissions = ["DATA_LOCATION_ACCESS"]

  depends_on = [
    aws_lakeformation_resource.buckets
  ]
}