data "aws_secretsmanager_secret_version" "lab" {
  secret_id = "sixg-evolution/lab"
}

locals {
  lab = jsondecode(data.aws_secretsmanager_secret_version.lab.secret_string)

  kube_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = local.kube_exec.api_version
    command     = local.kube_exec.command
    args        = local.kube_exec.args
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = local.kube_exec.api_version
      command     = local.kube_exec.command
      args        = local.kube_exec.args
    }
  }
}

resource "kubernetes_namespace" "open5gs" {
  metadata { name = "open5gs" }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "udm_hnet" {
  metadata {
    name      = "open5gs-udm-hnet"
    namespace = kubernetes_namespace.open5gs.metadata[0].name
  }
  binary_data = local.lab.hnet
}

resource "kubernetes_secret" "ue_auth" {
  metadata {
    name      = "ue-auth"
    namespace = kubernetes_namespace.open5gs.metadata[0].name
  }
  data = {
    k   = local.lab.k
    opc = local.lab.opc
  }
}

resource "helm_release" "core" {
  name       = "open5gs-core"
  chart      = "${path.module}/../core/open5gs-core"
  namespace  = kubernetes_namespace.open5gs.metadata[0].name
  wait       = true
  timeout    = 900
  depends_on = [kubernetes_secret.udm_hnet]
}

resource "helm_release" "subscribers" {
  name          = "subscribers"
  chart         = "${path.module}/../charts/subscribers"
  namespace     = kubernetes_namespace.open5gs.metadata[0].name
  wait          = true
  wait_for_jobs = true
  timeout       = 600
  depends_on    = [helm_release.core, kubernetes_secret.ue_auth]
}

resource "helm_release" "ueransim" {
  name       = "ueransim"
  chart      = "${path.module}/../charts/ueransim"
  namespace  = kubernetes_namespace.open5gs.metadata[0].name
  wait       = true
  timeout    = 600
  depends_on = [helm_release.subscribers]
}
