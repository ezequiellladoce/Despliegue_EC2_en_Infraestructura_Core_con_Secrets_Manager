provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.priv_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  name = var.Secret_Key
  description = "Name of the secret key"
  tags = {
    Name = "EC2-Key-4"
  }
}

resource "aws_secretsmanager_secret_version" "secret_priv" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.priv_key.private_key_pem
}

output "sb_id" {
  value = aws_subnet.subnet_public.id
}

output "sg_id" {
  value = [aws_security_group.sg_22_80.id]
}

terraform {
  backend "s3" {
    bucket = "tfbackup"
    key    = "tfbkcore/"
    region = "us-east-2"
  }
}
