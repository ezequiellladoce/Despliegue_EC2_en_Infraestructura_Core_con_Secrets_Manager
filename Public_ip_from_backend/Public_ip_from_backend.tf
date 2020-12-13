provider "aws" {
  region = "us-east-2"
}

data "terraform_remote_state" "LTFS" {
  backend = "s3"
  config = {
      bucket = "tfbackup"
      key    = "tfbkec2/"
      region = "us-east-2"
  }
}

output "pub_ip" {
  value = data.terraform_remote_state.LTFS.outputs.public_ip
}


