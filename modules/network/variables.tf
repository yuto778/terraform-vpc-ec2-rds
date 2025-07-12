variable "vpc_cidr_block" {
  type        = string
  description = "vpcのcidrブロック"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "パブリックサブネットのcidrリスト"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "プライベートサブネットのcidrリスト"
}

variable "project" {
  type        = string
  description = "リソースTagの名前"
}
