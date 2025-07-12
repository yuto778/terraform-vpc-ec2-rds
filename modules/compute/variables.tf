variable "instance_type" {
  type        = string
  description = "ec2インスタンスのタイプ"
}

variable "ami_id" {
  type        = string
  description = "AMIのID"
}

variable "vpc_id" {
  type        = string
  description = "VPCのID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "パブリックサブネットのCIDRリスト"
}



variable "project" {
  type        = string
  description = "プロジェクトの名前"
}

variable "alb_target_group_arn" {
  type        = string
  description = "ALBのターゲットグループのARN"
}

variable "alb_sg_id" {
  type        = string
  description = "ALBのセキュリティグループのID"
}


