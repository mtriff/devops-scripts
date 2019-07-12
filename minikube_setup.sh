#!/bin/bash

# Setup a local Kubernetes cluster, should be used for testing/experimentation only
# This assumes you have already run devops_setup.sh

set -e

echo "Installing VirtualBox as the virtualization layer..."
apt install virtualbox virtualbox-ext-pack

echo "Installing Minikube..."
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version

echo "Setup Minikube cluster..."
minikube start

echo "Getting cluster status..."
kubectl cluster-info

echo "Configuring Helm with the cluster..."
helm init

echo "Minikube has been installed and configured. Access your Minikube VM using `minikube ssh`"
