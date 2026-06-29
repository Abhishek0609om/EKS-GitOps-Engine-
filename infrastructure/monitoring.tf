resource "helm_release" "prometheus_stack" {
  name             = "kube-prom-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "86.2.3"

  values = [file("../monitoring/kube-prom-stack-values.yaml")]

  depends_on = [module.eks]
}
