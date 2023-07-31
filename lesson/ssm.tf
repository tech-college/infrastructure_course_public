resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "Database Username"
}

resource "random_password" "db_password" {
  length           = 20
  override_special = "!#%&()*+,-./;<=>?@[]^_{|}~"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  value       = random_password.db_password.result
  type        = "SecureString"
  description = "Database Password"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "random_password" "rds_admin_password" {
  length           = 20
  override_special = "!@#$%^&*()_+-="
}

resource "aws_ssm_parameter" "rds_admin_password" {
  name        = "/rds/password"
  value       = random_password.rds_admin_password.result
  type        = "SecureString"
  description = "RDS Admin Password"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "random_password" "pipeline" {
  length           = 20
  override_special = "!@#$%^&*()_+-="
}

resource "aws_ssm_parameter" "pipeline" {
  name        = "/pipeline/password"
  value       = random_password.pipeline.result
  type        = "SecureString"
  description = "Pipeline Password"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
