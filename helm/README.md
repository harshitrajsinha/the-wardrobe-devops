* As per ChatGPT, we should not create namespace via yaml when using helm. Either create namespace along with install command:
```
helm upgrade --install cartservice ./cartservice -f shared-ports.yaml \
  --namespace cartns \
  --create-namespace
```

* Use existing namespace if already created
```
helm upgrade --install cartservice ./cartservice -f shared-ports.yaml --namespace cartns
```

* Check if values are correctly replaced
```
cd helm/the-wardrobe
helm template cartservice ./cartservice -f shared-ports.yaml
```

* Check for linting
```
cd helm/the-wardrobe
helm lint cartservice ./cartservice -f shared-ports.yaml
```

* Whenever values.yaml or any template is modified:
```
helm upgrade cartservice ./cartservice -f shared-ports.yaml -n cartns
```

```
helm uninstall cartservice -n cartns
```

<hr>

* In this project a common file `shared-ports.yaml` is referenced as config yaml of each service uses port no of other service.

```

* For cart service: app.yaml
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cart
spec:
  destination:
    namespace: cartns
    server: https://kubernetes.default.svc
  source:
    path: helm/cartservice
    repoURL: https://github.com/harshitrajsinha/the-wardrobe-devops.git
    targetRevision: HEAD
    helm:
      valueFiles:
        - ../shared-ports.yaml
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
      enabled: true
```


### Learnings

1. ingress -> public subnet id tagging for auto-discovery by alb controller
2. using external tools for fetching secret values for manifest + argocd
3. dependency graph: ingress installed via helm (not managed by terraform) creates hanging problem


