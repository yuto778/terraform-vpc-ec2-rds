variable "project" {
  type        = string
  description = "プロジェクトの名前"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "パブリックサブネットのCIDRリスト"
}

variable "vpc_id" {
  type        = string
  description = "VPCのID"
}

variable "health_check_path" {
  type    = string
  default = "/health.html"
}

