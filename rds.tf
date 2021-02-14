resource "aws_db_instance" "main" {
  name                   = "wp"
  identifier             = "wp"
  allocated_storage      = "50"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  publicly_accessible    = false
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Allowed subnets for RDS cluster instances"
  subnet_ids  = module.networking.private_subnets
}

resource "aws_security_group" "rds_security_group" {
  name        = "wordpress-rds-sg"
  description = "Only allow ingress from wordpress EC2 instances on port 3306"
  vpc_id      = module.networking.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
