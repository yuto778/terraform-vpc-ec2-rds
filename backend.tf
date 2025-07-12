terraform {
  backend "s3" {
    bucket               = "vpc-ec2-rds-statefile-start-20250705"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "envs"
    region               = "ap-northeast-1"
    dynamodb_table       = "vpc-ec2-rds-statelock-start-20250705"
    encrypt              = true
  }
}
