#!/bin/bash

#############
# Harshit Raj Sinha
#
# This shell scripts installs necessary packages for bastion host on instance installation
#############

set -euo pipefail

exec > >(tee -a /tmp/user-data.log) 2>&1

REGION="us-east-1"
CLUSTER_NAME="wardrobe-cluster"

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install AWS CLI v2

if ! command -v aws >/dev/null 2>&1; then
    apt-get install -y unzip curl
    cd /tmp
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
    unzip -q awscliv2.zip
    ./aws/install
fi

# Install kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    curl -fsSL \
      -o /usr/local/bin/kubectl \
      "https://amazon-eks.s3.us-west-2.amazonaws.com/1.30.0/2024-05-12/bin/linux/amd64/kubectl"
    chmod +x /usr/local/bin/kubectl
fi

# Configure kubeconfig
mkdir -p /home/ubuntu/.kube

sudo -u ubuntu aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${CLUSTER_NAME}" \
    --kubeconfig /home/ubuntu/.kube/config

chown -R ubuntu:ubuntu /home/ubuntu/.kube


##############################################################
# Install git
if ! command -v git >/dev/null 2>&1; then
    sudo apt-get install -y git
fi

# Clone project repository
cd /home/ubuntu
if [ ! -d "the-wardrobe-devops" ]; then
    git clone https://github.com/harshitrajsinha/the-wardrobe-devops.git
fi
sudo chown -R ubuntu:ubuntu the-wardrobe-devops

##############################################################
# Install terraform
if ! command -v terraform >/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y terraform
fi

##############################################################

# Install Helm

if ! command -v helm >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Add argocd repo
helm repo add argo https://argoproj.github.io/argo-helm

# Add prometheus repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

# Install Argo CD

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --wait

# Install Prometheus + Grafana

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --wait

##############################################################