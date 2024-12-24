provider "aws" {
  region = "us-east-1"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

# Declare input variable for password
# variable "db_password" {
#   description = "The password for the database."
#   type        = string
#   sensitive   = true
# }

variable "labrole" {
  description = "The ARN of the IAM role to assign to the ECS task"
  type        = string
  default     = "arn:aws:iam::058264427980:role/LabRole"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "db_user"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "C:\\Users\\niels\\.ssh\\ssh-key-bastion.pub"
}
