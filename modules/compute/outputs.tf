# セキュリティグループの出力
output "web_sg_id" {
  value = aws_security_group.web.id
}
