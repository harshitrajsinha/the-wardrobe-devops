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
aws eks update-kubeconfig \
    --region "${REGION}" \
    --name "${CLUSTER_NAME}"


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