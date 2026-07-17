locals {

  application_namespaces = [
    "redisns",
    "cartns",
    "productcatalogns",
    "currencyns",
    "checkoutns",
    "frontendns",
    "paymentns",
    "shippingns",
    "argocd"
  ]
}

resource "kubernetes_namespace_v1" "application" {

  for_each = toset(local.application_namespaces)

  metadata {

    name = each.value

    labels = {
      managed-by = "terraform"
    }

  }
}