#!/bin/bash

# Deletes all files created by generate_certificates.sh and
# cleans up all files. generate_certificates.sh can be re-run
# after this script

set -e

# Make sure we are running this script from the directory the script is in
cd "${0%/*}"

echo "Cleaning the root folder..."
rm -f root/ca/certs/*.pem
rm -f root/ca/private/*.pem
rm -f root/ca/crl/*.pem
rm -f root/ca/openssl.cnf

rm -f root/ca/index.txt
touch root/ca/index.txt

rm -f root/ca/serial
echo 1000 > root/ca/serial

echo "Cleaning the intermediate folder..."
rm -f intermediate/certs/*.pem
rm -f intermediate/private/*.pem
rm -f intermediate/crl/*.pem
rm -f intermediate/csr/*.pem
rm -f intermediate/openssl.cnf

rm -f intermediate/index.txt
touch intermediate/index.txt

rm -f intermediate/serial
echo 1000 > intermediate/serial

echo "Cleaning the client folder..."
rm -f client/certs/*.pem
rm -f client/private/*.pem
rm -f client/csr/*.pem
