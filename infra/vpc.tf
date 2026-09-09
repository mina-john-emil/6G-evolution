module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnet_cidrs
  private_subnets = local.private_subnet_cidrs

  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  single_nat_gateway      = true   # one NAT gateway only — keeps cost minimal

  tags = local.tags
}
