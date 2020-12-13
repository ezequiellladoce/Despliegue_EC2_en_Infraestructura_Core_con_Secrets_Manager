variable "aws_region" {
  description = "Region for the deploy"
  default     = "us-east-2"
}

variable "key_name" {
  description = "Name for the KEY"
  default = "key_2"
}

variable "Secret_Key" {
  description = "Name for the AWS Secret Key"
  default = "EC2-key-4"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default     = "10.1.0.0/24"
}

