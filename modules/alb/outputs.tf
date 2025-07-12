#ロードバランサーのdnsの出力
output "aws_dns" {
  value = aws_lb.this.dns_name
}

#ALBのセキュリティグループの出力
output "alb_sg_id" {
  value = aws_security_group.alb.id
}

#ALBのターゲットグループARNの出力
output "alb_target_group_arn" {
  value = aws_lb_target_group.web.arn
}
