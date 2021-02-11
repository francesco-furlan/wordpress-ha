variable "project" {
  description = "The project name"
}

variable "env" {
  description = "The environment"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
}

variable "vpc_public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}
