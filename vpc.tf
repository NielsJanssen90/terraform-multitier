# VPC
resource "aws_vpc" "flaskapp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Flaskapp-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.flaskapp_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Flaskapp-subnet-public-us-east-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.flaskapp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Flaskapp-subnet-public-us-east-1b"
  }
}

# Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.flaskapp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Flaskapp-subnet-private-us-east-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.flaskapp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Flaskapp-subnet-private-us-east-1b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "flaskapp_igw" {
  vpc_id = aws_vpc.flaskapp_vpc.id
  tags = {
    Name = "Flaskapp-igw"
  }
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.flaskapp_vpc.id
  tags = {
    Name = "Flaskapp-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.flaskapp_igw.id
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
#   vpc_id               = aws_vpc.flaskapp_vpc.id
#   service_name         = "com.amazonaws.${var.region}.ecr.dkr"
#   vpc_endpoint_type    = "Interface"
#   private_dns_enabled  = true
#   security_group_ids   = [aws_security_group.endpoint_sg.id]
#   subnet_ids           = [aws_subnet.private_a.id, aws_subnet.private_b.id]

#   tags = {
#     Name = "ECR-DKR-Endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api_endpoint" {
#   vpc_id               = aws_vpc.flaskapp_vpc.id
#   service_name         = "com.amazonaws.${var.region}.ecr.api"
#   vpc_endpoint_type    = "Interface"
#   private_dns_enabled  = true
#   security_group_ids   = [aws_security_group.endpoint_sg.id]
#   subnet_ids           = [aws_subnet.private_a.id, aws_subnet.private_b.id]

#   tags = {
#     Name = "ECR-API-Endpoint"
#   }
# }

# Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "Flaskapp-NAT-EIP"
  }
}

# NAT Gateway to enable internet access for private subnets
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "Flaskapp-NAT-Gateway"
  }
}

# Route table for private subnets to direct traffic through the NAT Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.flaskapp_vpc.id

  tags = {
    Name = "Flaskapp-Private-RT"
  }
}

# Route in the private route table to send all outbound traffic to the NAT Gateway
resource "aws_route" "private_internet_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}


