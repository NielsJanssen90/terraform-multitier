# Fetch your current public IP using an HTTP request
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

output "my_ip" {
  value = chomp(data.http.my_ip.response_body)
}

# Key Pair for Bastion Host
resource "aws_key_pair" "bastion_key" {
  key_name   = "ssh-key-bastion"
  public_key = file(var.ssh_public_key_path)
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion_host" {
  ami                    = "ami-01816d07b1128cd2d" # Replace with the latest Amazon Linux 2 AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion_key.key_name
  subnet_id              = aws_subnet.public_a.id # Place the bastion in the public subnet
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # User data script to install MariaDB 10.5
  user_data = <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras enable mariadb10.5
    sudo dnf install -y mariadb105
  EOF

  tags = {
    Name = "Bastion-Host"
  }
}

# Output the Bastion Host Public IP
output "bastion_host_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion_host.public_ip
}


