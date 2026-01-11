output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet" {
  value = [aws_subnet.public_subnet_1, aws_subnet.public_subnet_2]
}

output "jenkins_subnet" {
  value = aws_subnet.jenkins_private_subnet
}

output "k3s_subnet" {
  value = aws_subnet.k3s_private_subnet
}
