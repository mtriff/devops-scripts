#!/bin/bash

# Setup a local Kubernetes cluster, should be used for testing/experimentation only
# This assumes you have already run devops_setup.sh
# NOTE: This script must be run with sudo

set -e

echo "Installing VirtualBox as the virtualization layer..."
apt install -y virtualbox virtualbox-ext-pack

echo "Installing Minikube..."
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version

echo "Setup Minikube cluster..."
# Run the following commands as a regular user so that kubectl can be used without sudo in the future
sudo -u $(logname) minikube start

echo "Getting cluster status..."
sudo -u $(logname) kubectl cluster-info

echo "Minikube has been installed and configured. Access your Minikube VM using `minikube ssh`"
