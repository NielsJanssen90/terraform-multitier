# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "flaskapp_db_password" {
  name = "flaskapp-db-password"

  tags = {
    Name = "flaskapp-db-password"
  }
}

# Secrets Manager Secret Version (to store the initial secret value)
resource "aws_secretsmanager_secret_version" "flaskapp_db_password" {
  secret_id = aws_secretsmanager_secret.flaskapp_db_password.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.flaskapp_db_password.result
  })
}

# Random Password Generation
resource "random_password" "flaskapp_db_password" {
  length           = 24
  special          = true
  override_special = "!#%^&*()-_=+[]{}"
}