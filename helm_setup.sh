#!/bin/bash

# Sets up Helm with RBAC
# To be run after devops_setup.sh, and after Kubernetes cluster has been connected
# Will create two namespaces, one for devops/infrastructure, one for apps/deploying

## http://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10 

set -e

# Create Helm and Tiller Service Accounts, Roles, RoleBindings
kubectl create -f cluster-manifest.yaml

# Create Certificate Authority to enable TLS communiction
./certificates/generate_certificates.sh

## https://helm.sh/docs/using_helm/#generating-certificate-authorities-and-certificates
## https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

# Generate Tiller certificates

# Generate Helm client certificates

# Store certificate keys in a key manager
# https://artisticcheese.wordpress.com/2018/01/04/storing-arbitrary-text-file-in-azure-key-vault-as-secrets-ssh-keys-cer-files-etc/

# Deploy Tiller
helm init --service-account tiller \
  --tiller-namespace dev \
  --tiller-tls \
  --tiller-tls-cert certificates/client/certs/dev.tiller.cert.pem \
  --tiller-tls-key certificates/client/private/dev.tiller.key.pem \
  --tiller-tls-verify \
  --tls-ca-cert certificates/intermediate/certs/ca-chain.cert.pem

helm init --service-account tiller \
  --tiller-namespace prod \
  --tiller-tls \
  --tiller-tls-cert certificates/client/certs/prod.tiller.cert.pem \
  --tiller-tls-key certificates/client/private/prod.tiller.key.pem \
  --tiller-tls-verify \
  --tls-ca-cert certificates/intermediate/certs/ca-chain.cert.pem

# Create a Kubeconfig file to specify access for the Helm client

