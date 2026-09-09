locals {
  name    = "sixg-evolution"
  region  = "us-east-1"
  azs = ["us-east-1a", "us-east-1b"]

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.3.0/24"]

  cluster_name    = "sixg-evolution-core"
  cluster_version = "1.31"

  tags = {
    Project     = local.name
    Terraform   = "true"
    Environment = "grad-project"
  }
}
