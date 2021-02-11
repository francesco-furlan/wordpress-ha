data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "nat" {
  count = length(var.vpc_private_subnets)
  vpc   = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc = true

  name = "${var.project}-${var.env}-vpc"
  cidr = var.vpc_cidr

  azs                 = data.aws_availability_zones.available.names
  public_subnets      = var.vpc_public_subnets
  private_subnets     = var.vpc_private_subnets
  external_nat_ip_ids = aws_eip.nat.*.id

  enable_nat_gateway     = true
  single_nat_gateway     = false
  reuse_nat_ips          = true
  enable_dns_hostnames   = true

  tags = {
    Project     = var.project
    Environment = var.env
  }
}
