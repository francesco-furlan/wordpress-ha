terraform {
  backend "s3" {
    bucket = "ff-wordpress-ha-tf"
    key    = "tfstate.json"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}

module "networking" {
  source              = "./modules/networking/"
  project             = var.project
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  vpc_public_subnets  = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets
}