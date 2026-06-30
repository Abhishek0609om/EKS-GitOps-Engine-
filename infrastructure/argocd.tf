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

resource "kubernetes_manifest" "argocd_application" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "phoenix-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/Abhishek0609om/phoenix-manifests-.git"
        targetRevision = "main"
        path           = "./"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}