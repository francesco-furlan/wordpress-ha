resource "aws_security_group" "wp_alb" {
  name        = "wordpress-http-lb"
  description = "Allow http inbound"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10.0"

  name = "wordpress-ha-alb-${var.env}"

  load_balancer_type = "application"

  vpc_id          = module.networking.vpc_id
  security_groups = [aws_security_group.wp_alb.id]
  subnets         = module.networking.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  target_groups = [
    {
      name_prefix          = "wp"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 10
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        port                = 80
        matcher             = "200-304"
      }
    }
  ]

  tags = {
    Project = var.project
  }
}
