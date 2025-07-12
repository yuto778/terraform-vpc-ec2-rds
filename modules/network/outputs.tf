#VPC_IDの出力
output "vpc_id" {
  value = aws_vpc.this.id
}

###############################################

#パブリックサブネットの出力
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

###############################################

#プライベートサブネットの出力
output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}
