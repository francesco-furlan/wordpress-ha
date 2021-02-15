resource "aws_key_pair" "bastion" {
  key_name   = "bastion_key"
  public_key = file("bastion_key.pub")
  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-00aa4671cbf840d82"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion.key_name
  subnet_id                   = element(module.networking.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  tags = {
    Name    = "${var.project}-bastion"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.project}-bastion"
  vpc_id = module.networking.vpc_id
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
    Name    = "${var.project}-bastion"
    Project = var.project
  }
}
