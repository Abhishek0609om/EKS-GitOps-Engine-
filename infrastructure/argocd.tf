resource "helm_release" "argocd" {
  depends_on = [module.eks,module.vpc,null_resource.helm_repos]

  name      = "argocd"
  namespace = "argocd"

  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "7.7.7"
  replace = true
  values = [
    file("../helm/argocd/values.yaml")
  ]

}

resource "null_resource" "helm_repos" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = "helm repo add argo https://argoproj.github.io/argo-helm; helm repo add prometheus-community https://prometheus-community.github.io/helm-charts; helm repo update"
    interpreter = ["powershell", "-command"]
  }
}

resource "null_resource" "argocd_application" {
  depends_on = [helm_release.argocd,module.eks,module.vpc, null_resource.helm_repos]


  triggers = {
    application_yaml = filemd5("../argocd/application.yaml")
  }

  # this run  during 'terraform apply'
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name phoenix-cluster --region ap-south-1 && kubectl apply -f ../argocd/application.yaml"
  }


  provisioner "local-exec" {
    when = destroy
    command = "aws eks update-kubeconfig --name phoenix-cluster --region ap-south-1 && kubectl delete -f ../argocd/application.yaml --ignore-not-found=true"
  }
}