variable "project" {
  type        = string
  description = "プロジェクトの名前"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "ami_id" {
  type        = string
  default     = "ami-01ead1eca9a200e01"
  description = "AMIのID"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2のインスタンスタイプ"
}

variable "db_password" {
  type        = string
  description = "データベースのパスワード"
}

