resource "aws_db_subnet_group" "flaskapp" {
  name       = "flaskapp-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "flaskapp-db-subnet-group"
  }
}