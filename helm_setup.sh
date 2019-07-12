#!/bin/bash

# Sets up Helm with RBAC
# To be run after devops_setup.sh, and after Kubernetes cluster has been connected
# Will create two namespaces, one for devops/infrastructure, one for apps/deploying

## http://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10 
## https://helm.sh/docs/using_helm/#generating-certificate-authorities-and-certificates

# Create Helm and Tiller Service Accounts

# Create Helm and Tiller Roles and RoleBindings

# Create Certificate Authority to enable TLS communiction

# Generate Tiller certificates

# Generate Helm client certificates

# Store certificateds in a key manager

# Deploy Tiller

# Create a Kubeconfig file to specify access for the Helm client

