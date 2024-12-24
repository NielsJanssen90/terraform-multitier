data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "flaskapp_repo" {
  name                 = "web-server/flaskapp"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "FlaskApp-ECR"
    Environment = "Production"
  }
}

resource "null_resource" "docker_packaging" {
  provisioner "local-exec" {
    command = <<EOF
    git clone https://github.com/NielsJanssen90/FlaskApp flaskapp_repo

    cd flaskapp_repo

    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com

    docker build -t "${aws_ecr_repository.flaskapp_repo.repository_url}:latest" -f dockerfile .

    docker push "${aws_ecr_repository.flaskapp_repo.repository_url}:latest"
    EOF
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_repository.flaskapp_repo,
  ]
}
