provider "aws" {
  region = "us-east-2"
}

data "terraform_remote_state" "LTFS" {
  backend = "s3"
  config = {
      bucket = "tfbackup"
      key    = "tfbkcore/"
      region = "us-east-2"
  }
}

resource "aws_instance" "EC2-Deploy" {
  ami                         = "ami-03657b56516ab7912"
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.LTFS.outputs.sb_id
  vpc_security_group_ids      = data.terraform_remote_state.LTFS.outputs.sg_id
  associate_public_ip_address = true
  key_name                    = "key_2"
  user_data = " ${file("Bash_install.sh")} "
  tags = {
    Name = "EC2-Deploy"
  }
}

output "public_ip" {
  value = aws_instance.EC2-Deploy.public_ip
}

terraform {
  backend "s3" {
    bucket = "tfbackup"
    key    = "tfbkec2/"
    region = "us-east-2"
  }
}
