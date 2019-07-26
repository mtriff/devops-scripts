#!/bin/bash

# Creates a certificate authority and generates certificates 
# for use by Helm and Tiller
#
# Based on this tutorial: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

set -e

# Make sure we are running this script from the directory the script is in
cd "${0%/*}"

pushd root/ca > /dev/null
echo "Creating root certificate configuration..."
sed 's?DIR_FOR_ROOT_CA_GOES_HERE?'`pwd`'?g' openssl.template.cnf > openssl.cnf 

echo "Creating the root key..."
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

echo "Creating the root certificate..."
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

#--------------------------------------------------------#
popd > /dev/null
pushd intermediate/ca > /dev/null
echo "Creating intermediate certificate configuration..."
sed 's?DIR_FOR_INTERMEDIATE_CA_GOES_HERE?'`pwd`'?g' openssl.template.cnf > openssl.cnf 

popd > /dev/null
pushd root/ca > /dev/null
echo "Creating the intermediate key..."
openssl genrsa -aes256 \
      -out ../../intermediate/private/intermediate.key.pem 4096
chmod 400 ../../intermediate/private/intermediate.key.pem

echo "Creating intermediate certificate signing request, all details should match details for the root certificate, except the 'Common Name', which must differ."
openssl req -config ../../intermediate/openssl.cnf -new -sha256 \
      -key ../../intermediate/private/intermediate.key.pem \
      -out ../../intermediate/csr/intermediate.csr.pem

echo "Creating intermediate certificate..."
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in ../../intermediate/csr/intermediate.csr.pem \
      -out ../../intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem

echo "Verifying intermediate certificate, expecting 'OK'..."
openssl verify -CAfile certs/ca.cert.pem \
      ../../intermediate/certs/intermediate.cert.pem

echo "Creating chained root-intermediate certificate..."
cat ../../intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > ../../intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

#--------------------------------------------------------#
echo "Creating 2 client keys..."
openssl genrsa -aes256 \
      -out ../../client/private/dev.tiller.key.pem 2048
chmod 400 ../../client/private/dev.tiller.key.pem 2048

openssl genrsa -aes256 \
      -out ../../client/private/prod.tiller.key.pem 2048
chmod 400 ../../client/private/prod.tiller.key.pem 2048

echo "Creating 2 client certificate signing requests, the 'Common Name' must differ from the previously used common names (and from each other)"
echo "Creating Tiller Dev CSR..."
openssl req -config ../../intermediate/openssl.cnf \
      -key ../../client/private/dev.tiller.key.pem \
      -new -sha256 -out ../../client/csr/dev.tiller.csr.pem

echo "Creating Tiller Prod CSR..."
openssl req -config ../../intermediate/openssl.cnf \
      -key ../../client/private/prod.tiller.key.pem \
      -new -sha256 -out ../../client/csr/prod.tiller.csr.pem

echo "Creating 2 client certificates..."
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 1825 -notext -md sha256 \
      -in ../../client/csr/dev.tiller.csr.pem \
      -out ../../client/certs/dev.tiller.cert.pem
chmod 444 ../../client/certs/dev.tiller.cert.pem

openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 1825 -notext -md sha256 \
      -in ../../client/csr/prod.tiller.csr.pem \
      -out ../../client/certs/prod.tiller.cert.pem
chmod 444 ../../client/certs/prod.tiller.cert.pem

echo "Verifying intermediate certificate, expecting 'OK'..."
openssl verify -CAfile ../../intermediate/certs/ca-chain.cert.pem \
      ../../client/certs/dev.tiller.cert.pem
openssl verify -CAfile ../../intermediate/certs/ca-chain.cert.pem \
      ../../client/certs/prod.tiller.cert.pem

popd > /dev/null
echo "Certificate generation completed."