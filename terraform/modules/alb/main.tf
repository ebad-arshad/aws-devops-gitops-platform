resource "aws_lb" "alb" {
  name            = "alb"
  security_groups = [var.alb_sg.id]
  subnets         = [for subnet in var.public_subnet : subnet.id]

  tags = {
    Name        = "ALB-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Target Group for the ArgoCD (K3s)
resource "aws_lb_target_group" "k3s_tg" {
  name     = "k3s-tg-${terraform.workspace}"
  port     = 30001
  protocol = "HTTP" # App runs HTTP
  vpc_id   = var.vpc.id

  health_check {
    # Match the port here as well
    port                = "30001"
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "ALB-K3S-TG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Target Group for App
resource "aws_lb_target_group" "api_gate_tg" {
  name     = "api-gate-tg-${terraform.workspace}"
  port     = 30002
  protocol = "HTTP"
  vpc_id   = var.vpc.id

  health_check {
    port     = "30002"
    path     = "/apis/healthz" # Or the specific health check your API uses
    matcher  = "200-399"
  }
}

# Target Group for Jenkins
resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg-${terraform.workspace}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc.id

  health_check {
    path    = "/jenkins/login"
    port    = "8080"
    matcher = "200-399"
  }

  tags = {
    Name        = "ALB-Jenkins-TG-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group_attachment" "jenkins_attach" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = var.jenkins_instance.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "k3s_attach" {
  target_group_arn = aws_lb_target_group.k3s_tg.arn
  target_id        = var.k3s_instance.id
  port             = 30001
}

resource "aws_lb_target_group_attachment" "api_gate_attach" {
  target_group_arn = aws_lb_target_group.api_gate_tg.arn
  target_id        = var.k3s_instance.id
  port             = 30002
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

resource "aws_lb_listener_rule" "api_gate_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 90 # Higher priority than the default (lower number = higher priority)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gate_tg.arn
  }

  condition {
    path_pattern {
      values = ["/apis*"]
    }
  }
}