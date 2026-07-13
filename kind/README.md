1. Create kind cluster
```kind create cluster --name demo-cluster --config config.yaml```

2. Load image (if not pulling from remote registry rather from local docker)
```kind --name demo-cluster load docker-image harshitrajsinha/van-client:latest```

3. Verify the image pulled successfully
```docker exec -it demo-cluster-control-plane crictl images```

----
* Exec into node: ```docker exec -it demo-cluster-worker bash```
* Exec into container: ```crictl exec -it <container-id> sh```
* Verify a container is running inside node: ```crictl ps```