resource "aws_instance" "jenkins_instance" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "t3.micro"
  key_name               = "terraform"
  subnet_id              = var.jenkins_subnet.id
  vpc_security_group_ids = [var.jenkins_security_group.id]
  associate_public_ip_address = false

  user_data = file("./scripts/jenkins.sh")

  tags = {
    Name        = "Jenkins-Instance-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_instance" "k3s_instance" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "c7i-flex.large"
  key_name               = "terraform"
  subnet_id              = var.k3s_subnet.id
  vpc_security_group_ids = [var.k3s_security_group.id]
  associate_public_ip_address = false

  user_data = file("./scripts/k3s.sh")

  tags = {
    Name        = "K3S-Instance-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
