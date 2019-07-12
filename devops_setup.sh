#!/bin/bash

# Install Local Tools for DevOps Work
# NOTE: Run this script with sudo

echo "Installing Azure command-line tools..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "Installing Kubernetes command-line tools..."
snap install kubectl --classic

echo "Installing Helm (k8s package manager) command-line tools..."
snap install helm --classic
