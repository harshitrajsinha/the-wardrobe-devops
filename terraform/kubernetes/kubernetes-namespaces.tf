locals {

  application_namespaces = [
    "redisns",
    "cartns",
    "productcatalogns",
    "currencyns",
    "checkoutns",
    "frontendns",
    "paymentns",
    "shippingns"
  ]
}

resource "kubernetes_namespace" "application" {

  for_each = toset(local.application_namespaces)

  metadata {

    name = each.value

    labels = {
      managed-by = "terraform"
    }

  }
}