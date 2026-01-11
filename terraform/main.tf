module "alb" {
  source           = "./modules/alb"
  alb_sg           = module.security.alb_sg
  public_subnet    = module.vpc.public_subnet
  vpc              = module.vpc.vpc
  jenkins_instance = module.instance.jenkins_instance
  k3s_instance     = module.instance.k3s_instance
}

module "instance" {
  source                 = "./modules/instance"
  jenkins_subnet         = module.vpc.jenkins_subnet
  k3s_subnet             = module.vpc.k3s_subnet
  jenkins_security_group = module.security.jenkins_security_group
  k3s_security_group     = module.security.k3s_security_group
}

module "security" {
  source = "./modules/security"
  vpc    = module.vpc.vpc
}

module "vpc" {
  source = "./modules/vpc"
}

# module "s3" {
#   source = "./modules/s3"
# }

# module "dynamodb" {
#   source = "./modules/dynamodb"
# }
