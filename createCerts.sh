#!/bin/bash

set -xe

export SUBCA_SAN_RESTRICTION=.dev.somedomain.com
export LEAF_SAN=myservice.dev.somedomain.com

rm -fr ca
rm -fr subca
rm -fr myservice

mkdir ca

cd ca
mkdir certs
mkdir crl
mkdir newcerts
mkdir private

touch index.txt
echo 2000 > serial
cd ..

echo "======================================"
echo "Generate ca.key"
openssl genrsa -aes256 -out ca/private/ca.key -passout pass:ca_secret_password 4096

echo "======================================"
echo "Create a self-signed certificate for the CA"
openssl req -new  -config ca.conf -passin pass:ca_secret_password -key ca/private/ca.key -x509 -out ca/certs/ca.crt

echo "======================================"
echo "Contents of the CA cert"
openssl x509 -noout -text -in ca/certs/ca.crt

echo "======================================"
echo "Create subCA key"
mkdir subca
cd subca
mkdir certs crl csr newcerts private
echo 1000 > crlnumber
echo 3000 > serial
touch index.txt
cd ..
openssl genrsa -aes256 -out subca/private/subca.key -passout pass:subca_secret_password 4096

echo "======================================"
echo "Create subCA csr"
CERT_SAN=NIL openssl req -new -sha256 -config subca.conf -passin pass:subca_secret_password -key subca/private/subca.key \
      -out subca/csr/subca.csr

echo "======================================"
echo "Contents of subCA cert"
openssl req -noout -text -in subca/csr/subca.csr

echo "======================================"
echo "Sign the subca"
openssl ca -config ca.conf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 \
   -in subca/csr/subca.csr -out subca/certs/subca.crt -passin pass:ca_secret_password

echo "======================================"
echo "Print the signed subca"
openssl x509 -noout -text -in subca/certs/subca.crt


echo "======================================"
echo "Verify the subca"
openssl verify -CAfile ca/certs/ca.crt subca/certs/subca.crt

echo "======================================"
echo "Create certificate chain"
cat subca/certs/subca.crt ca/certs/ca.crt > subca/certs/ca-subca-chain.crt

echo "======================================"
echo "View certificate chain"
keytool -printcert -v -file subca/certs/ca-subca-chain.crt

echo "======================================"
echo "Create key for service"
mkdir myservice
openssl genrsa -aes256 -passout pass:service_key_password -out myservice/myservice.key 2048

echo "======================================"
echo "Create csr for service"
CERT_SAN=$LEAF_SAN openssl req -config service-ssl-config.conf -key myservice/myservice.key -new -sha256 -out myservice/myservice.csr -passin pass:service_key_password


echo "======================================"
echo "Contents of service cert"
openssl req -noout -text -in myservice/myservice.csr

echo "======================================"
echo "Sign service csr"
CERT_SAN=$LEAF_SAN openssl ca -config subca.conf -extensions server_cert -extensions domain_ca -days 375 -notext -md sha256 -passin pass:subca_secret_password \
           -in myservice/myservice.csr -out myservice/myservice.crt


echo "======================================"
echo "View myservice cert"
openssl x509 -noout -text -in myservice/myservice.crt

echo "======================================"
echo "Combine certs for a web server"
cat myservice/myservice.crt subca/certs/subca.crt ca/certs/ca.crt  > myservice/web.crt

echo "======================================"
echo "Verify myservice's cert"
openssl verify -CAfile subca/certs/ca-subca-chain.crt myservice/web.crt