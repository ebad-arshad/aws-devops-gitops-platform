output "alb_sg" {
  value = aws_security_group.alb_sg
}

output "jenkins_security_group" {
  value = aws_security_group.jenkins_sg
}

output "k3s_security_group" {
  value = aws_security_group.k3s_sg
}