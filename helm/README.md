* As per ChatGPT, we should not create namespace via yaml when using helm. Either create namespace along with install command:
```
helm install cartservice ./cartservice -f shared-ports.yaml \
  --namespace cartns \
  --create-namespace
```

* Use existing namespace if already created
```
helm install cartservice ./cartservice -f shared-ports.yaml --namespace cartns
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

* In this project a common file `shared-ports.yaml` is referenced as config yaml of each service uses port no of other service.


* Install argocd and its ingress resource (make sure to change public subnet id in ingress file)
```
kubectl create namespace argocd  (if not created via terraform)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
cd kubernetes
kubectl apply -f argocd-ingress.yaml
```