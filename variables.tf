variable "project" {
  description = "The project name"
  default     = "wordpress-ha"
}

variable "env" {
  description = "The environment"
  default     = "dev"
}

variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.200.0.0/16"
}

variable "vpc_public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.200.48.0/24", "10.200.49.0/24", "10.200.50.0/24"]
}

variable "vpc_private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.200.0.0/20", "10.200.16.0/20", "10.200.32.0/20"]
}
