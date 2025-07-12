##############################
#IAMロール
resource "aws_iam_role" "ssm" {
  name = "${var.project}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = ["ec2.amazonaws.com"]
      },
      Action = ["sts:AssumeRole"]
    }]

  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project}-ssm-profile"
  role = aws_iam_role.ssm.name
}


##############################

#セキュリティグループ
resource "aws_security_group" "web" {
  name        = "${var.project}-web"
  vpc_id      = var.vpc_id
  description = "Allow HTTP ALB"


  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] #ALBからのアクセスを許可
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


##################################################

#起動テンプレート
resource "aws_launch_template" "web" {
  name_prefix            = "${var.project}-lt-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(file("${path.module}/userdata.sh"))
}

##################################################

#AutoScalingGroup
resource "aws_autoscaling_group" "web" {
  name             = "${var.project}-asg"
  desired_capacity = 1
  max_size         = 3
  min_size         = 1
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [var.alb_target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300


  tag {
    key                 = "Name"
    value               = "${var.project}-web"
    propagate_at_launch = true
  }
}
