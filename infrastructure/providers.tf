terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

  }

  backend "s3" {
    bucket         = "phoenix-tfstate-095055159123"
    key            = "phoenix-app/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "phoenix-tfstate-lock"
    encrypt        = true
  }

}


provider "aws" {

  region = "ap-south-1"

}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks.cluster_name
    ]
  }
}

provider "helm" {

  kubernetes {

    host = module.eks.cluster_endpoint

    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )

    exec {

      api_version = "client.authentication.k8s.io/v1beta1"

      command = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]

    }

  }

}