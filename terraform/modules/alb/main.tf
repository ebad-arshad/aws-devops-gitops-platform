resource "aws_lb" "alb" {
  name            = "alb"
  security_groups = [var.alb_sg.id]
  subnets         = [for subnet in var.public_subnet : subnet.id]

  tags = {
    Name        = "ALB-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Target Group for the Ecommerce App (K3s)
resource "aws_lb_target_group" "k3s_tg" {
  name     = "k3s-tg-${terraform.workspace}"
  port     = 80
  protocol = "HTTP" # App runs HTTP
  vpc_id   = var.vpc.id

  health_check {
    path = "/login" # Ensure your app responds here
  }

  tags = {
    Name        = "ALB-K3S-TG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Target Group for Jenkins
resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg-${terraform.workspace}"
  port     = 8080
  protocol = "HTTP" # Jenkins runs HTTP
  vpc_id   = var.vpc.id

  health_check {
    path = "/jenkins/login"
  }

  tags = {
    Name        = "ALB-Jenkins-TG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group_attachment" "jenkins_attach" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = var.jenkins_instance.id
  port             = 8080 # Jenkins default port
}

resource "aws_lb_target_group_attachment" "k3s_attach" {
  target_group_arn = aws_lb_target_group.k3s_tg.arn
  target_id        = var.k3s_instance.id
  port             = 80 # k3s default port
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  # Default: Send traffic to the K3s Ecommerce App
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s_tg.arn
  }

  tags = {
    Name        = "HTTP-Listener-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Rule: If path is /jenkins*, send to Jenkins Target Group
resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    path_pattern {
      values = ["/jenkins*"]
    }
  }

  tags = {
    Name        = "Jenkins-Listener-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
