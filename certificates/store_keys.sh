#!/bin/bash

set -e

# IN PROGRESS

# https://artisticcheese.wordpress.com/2018/01/04/storing-arbitrary-text-file-in-azure-key-vault-as-secrets-ssh-keys-cer-files-etc/


# Default keyvault is k8sCertAuthority, if you already have a keyvault,
# or would like to use a different name, call this script using:
#  KEYVAULT_NAME=yourName ./store_keys.sh
KEYVAULT_NAME=${KEYVAULT_NAME-k8sCertAuthority}
# RESOURCE_GROUP is mandatory
RESOURCE_GROUP=${RESOURCE_GROUP}

if ! az keyvault show --name $KEYVAULT_NAME > /dev/null 2&>1 ; then
  echo "The keyvault $KEYVAULT_NAME doesn't exist, creating it now..."
  az keyvault create              \
    --name $KEYVAULT_NAME         \
    --resource-group $RESOURCE_GROUP
fi