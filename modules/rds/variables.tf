variable "project" {
  type        = string
  description = "プロジェクトの名前"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "プライベートサブネットのCIDRリスト"
}

variable "vpc_id" {
  type        = string
  description = "VPCのID"
}

variable "web_sg_id" {
  type        = string
  description = "セキュリティグループのID"
}

variable "db_password" {
  type        = string
  description = "データベースのパスワード"
}

