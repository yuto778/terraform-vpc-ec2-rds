#DBサブネットグループ
resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnets"
  subnet_ids = var.private_subnet_ids
}

###########################################
#RDSセキュリティグループ
resource "aws_security_group" "rds" {
  name   = "${var.project}-rds"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_sg_id]
  }

}

###########################################
#RDSインスタンス
resource "aws_db_instance" "primary" {
  identifier              = "${var.project}-primary"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  multi_az                = true
  skip_final_snapshot     = true
  backup_retention_period = 1
}

