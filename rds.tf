# AWS RDS Instance resource
resource "aws_db_instance" "flaskapp" {
  identifier              = "flaskapp-database"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t4g.micro"
  username                = var.db_username
  password                = random_password.flaskapp_db_password.result
  db_name                 = "flaskappdb"
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  storage_encrypted       = true
  deletion_protection     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.flaskapp_db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.flaskapp.name

  tags = {
    Name = "flaskapp-database"
  }
}


# Output the RDS Endpoint to connect to via the bastion host
output "RDS_endpoint" {
  description = "The database endpoint to which you should connect usning the bastion host"
  value       = aws_db_instance.flaskapp.endpoint
}


