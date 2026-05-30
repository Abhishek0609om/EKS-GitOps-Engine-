# section 2 
#fetch available aws available zone dynamically 
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"


  name = "phoenix-app"
  cidr = "10.0.0.0/16"


  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_nat_gateway = true

  public_subnets_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnets_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = "production"
    project     = "phoenix"
  }
}