module "alb" {
  source             = "../../"
  name               = "example"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids
  access_logs_bucket = module.s3_lb_log.s3_bucket_id

  # NOTE: You can provision only HTTP, if enable_https_listener is set to false.
  enable_https_listener = false

  # WARNING: If in production environment, you should delete this parameter or change to true.
  enable_deletion_protection = false
}

module "vpc" {
  source                    = "git::https://github.com/tmknom/terraform-aws-vpc.git?ref=tags/2.0.1"
  cidr_block                = local.cidr_block
  name                      = "alb"
  public_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 8, 0), cidrsubnet(local.cidr_block, 8, 1)]
  public_availability_zones = data.aws_availability_zones.available.names
}

module "s3_lb_log" {
  source                = "git::https://github.com/tmknom/terraform-aws-s3-lb-log.git?ref=tags/2.0.0"
  name                  = "s3-lb-log-alb-${data.aws_caller_identity.current.account_id}"
  logging_target_bucket = module.s3_access_log.s3_bucket_id
  force_destroy         = true
}

module "s3_access_log" {
  source        = "git::https://github.com/tmknom/terraform-aws-s3-access-log.git?ref=tags/2.0.0"
  name          = "s3-access-log-alb-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

locals {
  cidr_block = "10.255.0.0/16"
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}
