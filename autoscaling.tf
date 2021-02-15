resource "aws_key_pair" "wp" {
  key_name   = "wp_key"
  public_key = file("wp_key.pub")
  lifecycle {
    ignore_changes = [public_key]
  }
}

data "template_file" "wordpress_setup" {
  template = file("scripts/wordpress_setup.sh")

  vars = {
    DB_PORT     = aws_db_instance.main.port
    DB_HOST     = aws_db_instance.main.address
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix     = "wp"
  image_id        = "ami-00aa4671cbf840d82"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.wp.key_name
  security_groups = [aws_security_group.main_wp_ec2.id]
  user_data       = data.template_file.wordpress_setup.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "main_wp_ec2" {
  vpc_id      = module.networking.vpc_id
  name        = "WP-SG"
  description = "security group for ec2 instances"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "WP-SG"
  }
}

resource "aws_autoscaling_group" "main" {
  name                      = "${var.project}-${var.env}-asg"
  vpc_zone_identifier       = module.networking.private_subnets
  launch_configuration      = aws_launch_configuration.main.name
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  depends_on = [
    aws_db_instance.main,
  ]

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = var.env
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.id
  alb_target_group_arn   = module.alb.target_group_arns[0]
}
