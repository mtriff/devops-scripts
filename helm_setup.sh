#!/bin/bash

# Sets up Helm with RBAC
# To be run after devops_setup.sh, and after Kubernetes cluster has been connected
# Will create two namespaces, one for devops/infrastructure, one for apps/deploying

## http://medium.com/@elijudah/configuring-minimal-rbac-permissions-for-helm-and-tiller-e7d792511d10 

set -e

# Create Helm and Tiller Service Accounts, Roles, RoleBindings
echo -e "\e[32mCreating namespaces, roles, service accounts, etc in the cluster...\e[0m"
kubectl create -f cluster-manifest.yaml

# Create Certificate Authority, Tiller and Helm certificates to enable TLS communication
echo -e "\e[32mCreating certificates for secure intra-cluster communication...\e[0m"
./certificates/generate_certificates.sh

# Store certificate keys in a key manager
# TODO: Call certificates/store_keys.sh

# Deploy Tiller
echo -e "\e[32mDeploying Tiller to DEV namespace...\e[0m"
helm init --service-account tiller \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --tiller-namespace dev \
  --tiller-tls \
  --tiller-tls-cert certificates/client/certs/dev.tiller.cert.pem \
  --tiller-tls-key certificates/client/private/dev.tiller.key.pem \
  --tiller-tls-verify \
  --tls-ca-cert certificates/intermediate/certs/ca-chain.cert.pem

echo -e "\e[32mDeploying Tiller to PROD namespace...\e[0m"
helm init --service-account tiller \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --tiller-namespace prod \
  --tiller-tls \
  --tiller-tls-cert certificates/client/certs/prod.tiller.cert.pem \
  --tiller-tls-key certificates/client/private/prod.tiller.key.pem \
  --tiller-tls-verify \
  --tls-ca-cert certificates/intermediate/certs/ca-chain.cert.pem

# Create a Kubeconfig file to specify access for the Helm client
NAMESPACE=devops ./get_kubeconfig.sh

echo -e "\e[Helm has been successfully initialized!\e[0m"
echo -e "\e[Make sure to use the '--tls' flag whenever using the 'helm' command\e[0m"