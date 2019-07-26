#!/bin/bash

# Creates a certificate authority and generates certificates 
# for use by Helm and Tiller
#
# Based on this tutorial: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

set -e

# Make sure we are running this script from the directory the script is in
cd "${0%/*}"

#-------------------------ROOT-------------------------#
pushd root/ca > /dev/null
echo -e "\e[32mCreating root certificate configuration...\e[0m"
sed 's?DIR_FOR_ROOT_CA_GOES_HERE?'`pwd`'?g' openssl.template.cnf > openssl.cnf 

if [ ! -f private/ca.key.pem ]; then
  echo -e "\e[32mCreating the root key...\e[0m"
  openssl genrsa -aes256 -out private/ca.key.pem 4096
  chmod 400 private/ca.key.pem
fi

if [ ! -f certs/ca.cert.pem ]; then
  echo -e "\e[32mCreating the root certificate...\e[0m"
  openssl req -config openssl.cnf \
        -key private/ca.key.pem \
        -new -x509 -days 7300 -sha256 -extensions v3_ca \
        -out certs/ca.cert.pem
fi

#-------------------------INTERMEDIATE-------------------------#
popd > /dev/null
pushd intermediate > /dev/null
echo -e "\e[32mCreating intermediate certificate configuration...\e[0m"
sed 's?DIR_FOR_INTERMEDIATE_CA_GOES_HERE?'`pwd`'?g' openssl.template.cnf > openssl.cnf 

popd > /dev/null
pushd root/ca > /dev/null
if [ ! -f ../../intermediate/private/intermediate.key.pem ]; then
  echo -e "\e[32mCreating the intermediate key...\e[0m"
  openssl genrsa -aes256 \
        -out ../../intermediate/private/intermediate.key.pem 4096
  chmod 400 ../../intermediate/private/intermediate.key.pem
fi

if [ ! -f ../../intermediate/csr/intermediate.csr.pem ]; then
echo -e "README: \e[93mCreating intermediate certificate signing request, all details should match details for the root certificate, except the 'Common Name', which must differ.\e[0m"
  openssl req -config ../../intermediate/openssl.cnf -new -sha256 \
        -key ../../intermediate/private/intermediate.key.pem \
        -out ../../intermediate/csr/intermediate.csr.pem
fi

if [ ! -f ../../intermediate/certs/intermediate.cert.pem ]; then
  echo -e "\e[32mCreating intermediate certificate...\e[0m"
  openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
        -days 3650 -notext -md sha256 \
        -in ../../intermediate/csr/intermediate.csr.pem \
        -out ../../intermediate/certs/intermediate.cert.pem
  chmod 444 ../../intermediate/certs/intermediate.cert.pem
fi

echo -e "\e[32mVerifying intermediate certificate, expecting 'OK'...\e[0m"
openssl verify -CAfile certs/ca.cert.pem \
      ../../intermediate/certs/intermediate.cert.pem

if [ ! -f ../../intermediate/certs/ca-chain.cert.pem ]; then
  echo -e "\e[32mCreating chained root-intermediate certificate...\e[0m"
  cat ../../intermediate/certs/intermediate.cert.pem \
        certs/ca.cert.pem > ../../intermediate/certs/ca-chain.cert.pem
  chmod 444 ../../intermediate/certs/ca-chain.cert.pem
fi

#-------------------------CLIENT-------------------------#
if [ ! -f ../../client/private/dev.tiller.key.pem ]; then
  echo -e "\e[32mCreating Tiller DEV client key...\e[0m"
  openssl genrsa -aes256 \
        -out ../../client/private/dev.tiller.key.pem 2048
  chmod 400 ../../client/private/dev.tiller.key.pem
fi

if [ ! -f ../../client/private/prod.tiller.key.pem ]; then
  echo -e "\e[32mCreating Tiller PROD client key...\e[0m"
  openssl genrsa -aes256 \
        -out ../../client/private/prod.tiller.key.pem 2048
  chmod 400 ../../client/private/prod.tiller.key.pem
fi

if [ ! -f ../../client/csr/dev.tiller.csr.pem ]; then
  echo -e "Creating Tiller Dev certificate signing request, \e[93mthe 'Common Name' must differ from the previously used common names (and from each other)...\e[0m"
  openssl req -config ../../intermediate/openssl.cnf \
        -key ../../client/private/dev.tiller.key.pem \
        -new -sha256 -out ../../client/csr/dev.tiller.csr.pem
fi

if [ ! -f ../../client/csr/prod.tiller.csr.pem ]; then
  echo -e "Creating Tiller Prod certificate signing request, \e[93mthe 'Common Name' must differ from the previously used common names (and from each other)...\e[0m"
  openssl req -config ../../intermediate/openssl.cnf \
        -key ../../client/private/prod.tiller.key.pem \
        -new -sha256 -out ../../client/csr/prod.tiller.csr.pem
fi

if [ ! -f ../../client/certs/dev.tiller.cert.pem ]; then
  echo -e "\e[32mCreating Tiller DEV client certificate...\e[0m"
  openssl ca -config ../../intermediate/openssl.cnf \
        -extensions server_cert -days 1825 -notext -md sha256 \
        -in ../../client/csr/dev.tiller.csr.pem \
        -out ../../client/certs/dev.tiller.cert.pem
  chmod 444 ../../client/certs/dev.tiller.cert.pem
fi

if [ ! -f ../../client/certs/prod.tiller.cert.pem ]; then
  echo -e "\e[32mCreating Tiller PROD client certificate...\e[0m"
  openssl ca -config ../../intermediate/openssl.cnf \
        -extensions server_cert -days 1825 -notext -md sha256 \
        -in ../../client/csr/prod.tiller.csr.pem \
        -out ../../client/certs/prod.tiller.cert.pem
  chmod 444 ../../client/certs/prod.tiller.cert.pem
fi

echo -e "\e[32mVerifying intermediate certificate, expecting 'OK'...\e[0m"
openssl verify -CAfile ../../intermediate/certs/ca-chain.cert.pem \
      ../../client/certs/dev.tiller.cert.pem
openssl verify -CAfile ../../intermediate/certs/ca-chain.cert.pem \
      ../../client/certs/prod.tiller.cert.pem

popd > /dev/null
echo -e "\e[32mCertificate generation completed.\e[0m"