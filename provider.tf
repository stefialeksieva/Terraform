provider "aws" {
  region = var.aws_region
}

# Creating SSH Key for EC2 Instances
resource "tls_private_key" "wordpress_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wordpress_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.wordpress_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.wordpress_key.private_key_pem
  filename = "${var.key_pair_name}.pem"
  file_permission = "0600"
}

