resource "helm_release" "argocd" {

  name = "argocd"

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

resource "null_resource" "argocd_application" {
  depends_on = [helm_release.argocd]

  triggers = {
    application_yaml = filemd5("../argocd/application.yaml")
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name phoenix-cluster --region ap-south-1 && kubectl apply -f ../argocd/application.yaml"
  }
}
