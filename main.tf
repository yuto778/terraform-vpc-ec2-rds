provider "aws" {
  region = var.region
}

####################################################

#VPC
module "vpc" {
  source               = "./modules/network"
  project              = var.project #envsで指定
  vpc_cidr_block       = var.vpc_cidr
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
}

######################################################

#ALB
module "alb" {
  source            = "./modules/alb"
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

}

####################################################

#起動テンプレートとAuto Scaling Group
module "compute" {
  source               = "./modules/compute"
  project              = var.project
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_sg_id            = module.alb.alb_sg_id
  alb_target_group_arn = module.alb.alb_target_group_arn
}

####################################################

#RDS

module "rds" {
  source             = "./modules/rds"
  project            = var.project
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  web_sg_id          = module.compute.web_sg_id
  db_password        = var.db_password #envsで指定
}
