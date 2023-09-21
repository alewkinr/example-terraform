# ref: https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs

# Generate usernames
locals {
  dbowners_names = tomap({ for _, v in var.db_names : v => "${v}_owner" })
}

# Generate password for user
resource "random_password" "dbowners_password" {
  for_each = local.dbowners_names

  length           = 32
  special          = true
  override_special = "_%@"
}

# Save password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "dbowner-credentials" {
  for_each = toset(var.db_names)

  name                    = "infra/db/${each.key}/users/${local.dbowners_names[each.key]}"
  recovery_window_in_days = 0

  depends_on = [random_password.dbowners_password]
}
resource "aws_secretsmanager_secret_version" "v1-secret" {
  for_each = aws_secretsmanager_secret.dbowner-credentials

  secret_id     = each.value.id
  secret_string = <<EOF
   {
    "username": "${local.dbowners_names[each.key]}",
    "password": "${random_password.dbowners_password[each.key].result}"
   }
EOF

  depends_on = [aws_secretsmanager_secret.dbowner-credentials]
}


data "aws_secretsmanager_secret" "data-dbowner-credentials" {
  for_each = aws_secretsmanager_secret.dbowner-credentials

  arn = each.value.arn

  depends_on = [aws_secretsmanager_secret_version.v1-secret]
}

data "aws_secretsmanager_secret_version" "v1-creds" {
  for_each = data.aws_secretsmanager_secret.data-dbowner-credentials

  secret_id = each.value.arn

  depends_on = [aws_secretsmanager_secret.dbowner-credentials]
}

# Create user for db
resource "postgresql_role" "dbrole" {
  for_each = data.aws_secretsmanager_secret_version.v1-creds

  name     = jsondecode(nonsensitive(each.value.secret_string)).username
  password = jsondecode(nonsensitive(each.value.secret_string)).password
  login    = true

  depends_on = [data.aws_secretsmanager_secret_version.v1-creds]
}

# Create new PSQL database
resource "postgresql_database" "db" {
  for_each = toset(var.db_names)

  name  = each.key
  owner = postgresql_role.dbrole[each.key].name

  connection_limit  = 100
  allow_connections = true

  encoding = "UTF8"

  depends_on = [postgresql_role.dbrole]
}