module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow all traffic between nodes (UDP for PFCP/GTP-U)"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }
  eks_managed_node_groups = {
    default = {
      capacity_type  = var.use_spot ? "SPOT" : "ON_DEMAND"
      instance_types = var.use_spot ? ["m7i-flex.large", "m7i.large", "m6i.large", "m5.large"] : ["m7i-flex.large"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      subnet_ids     = [module.vpc.private_subnets[0]]
    }
  }

  tags = local.tags
}
