resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG-${terraform.workspace}"
  vpc_id      = var.vpc.id

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

  tags = {
    Name = "ALB-SG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "jenkins_sg" {
  name   = "Jenkins-SG-${terraform.workspace}"
  vpc_id = var.vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "k3s_sg" {
  name   = "K3S-SG-${terraform.workspace}"
  vpc_id = var.vpc.id

  ingress {
    from_port       = 30001
    to_port         = 30001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true # Allows instances with THIS SG to talk to each other
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K3S-SG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}