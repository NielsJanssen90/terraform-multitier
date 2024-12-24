resource "aws_security_group" "flaskapp_db_sg" {
  name        = "Flaskapp-DB-SG"
  description = "Security group for RDS instance of FlaskApp"
  vpc_id      = aws_vpc.flaskapp_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FlaskApp-DB-SG"
  }
}

resource "aws_security_group" "flaskapp_lb_sg" {
  name        = "FlaskApp-LB-SG"
  vpc_id      = aws_vpc.flaskapp_vpc.id
  description = "Allow HTTP traffic to the load balancer"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "http" {
  name        = "FlaskApp-SG"
  description = "HTTP security group for ECS"
  vpc_id      = aws_vpc.flaskapp_vpc.id

ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_groups = [aws_security_group.flaskapp_lb_sg.id]
}
#Allow inbound HTTP traffic from anywhere
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Public access
  # }

  # Allow all outbound traffic (default behavior in AWS)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FlaskApp-SG"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "Bastion-SG"
  description = "Allow SSH access to bastion host"
  vpc_id      = aws_vpc.flaskapp_vpc.id

  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# resource "aws_security_group" "endpoint_sg" {
#   vpc_id = aws_vpc.flaskapp_vpc.id


  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"] # Public access
  #   security_groups = [aws_security_group.http.id] # Allow ECS task SG traffic
  # }
  # Allow inbound traffic from ECS tasks
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Public access
  #   security_groups = [aws_security_group.http.id] # Allow ECS task SG traffic
  # }

  #   ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Public access
  # }
  

  # Allow outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "ECR-Endpoint-SG"
#   }
# }

