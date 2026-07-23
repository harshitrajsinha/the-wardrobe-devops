1. Install EKS terraform resources (not kubernetes/)
* This will create bastion host (kuberentes/ needs to be installed through terraform from that bastion host)

2. Login to bastion host
* cd ${cloned-project}/terraform/kubernetes

3. Terraform apply kubernetes/
* This will ask for ARN of `alb-controller-role` as input (already created by iam.tf)

4. Install argocd via helm
```
helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --wait
```

* Install argocd ingress using different release name
cd to ${cloned-project}/helm/
```
helm upgrade --install argocd-ingress ./argocd \
  -f shared-ports.yaml \
  -n argocd
```

* Get secrets
```
kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d
```

5. Install all microservices app via argocd UI

6. Install prometheus stack
```
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --wait
```

* Install grafana and prometheus ingress using different release name

cd to ${cloned-project}/helm/
```
helm upgrade --install grafana-ingress ./grafana \
  -f shared-ports.yaml \
  -n monitoring
```
```
helm upgrade --install prometheus-ingress ./prometheus \
  -f shared-ports.yaml \
  -n monitoring
```

* Get password and username for grafana (assuming service name is prometheus-grafana)
```
kubectl get secret prometheus-grafana \
    -n monitoring \
    -o jsonpath="{.data.admin-password}" | base64 -d
```
```
kubectl get secret prometheus-grafana \
    -n monitoring \
    -o jsonpath="{.data.admin-user}" | base64 -d
```

7. Cleanup
NOTE: All these ingress (argocd, monitoring) are created via helm and frontend ingress via argocd, so terraform has no idea of these resources and creates problem when `terraform destroy` command is executed before cleaning up these resources.

* Delete all microservices app in argocd UI
* kubectl delete ingress frontend-ingress -n frontendns  (in case frontend-ingress is not deleted, check first)
```
helm uninstall argocd-ingress -n argocd
helm uninstall argocd -n argocd
helm uninstall grafana-ingress -n monitoring
helm uninstall prometheus-ingress -n monitoring
helm uninstall prometheus -n monitoring
```
* Now run `terraform destroy`

NOTE: If any of the ingress (say argocd) stucks on deletion then run: `kubectl patch ingress argocd-ingress -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge`