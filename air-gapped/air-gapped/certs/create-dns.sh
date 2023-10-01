#!/bin/bash

openssl genrsa -des3 -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 730 -out rootCA.pem
openssl x509 -in rootCA.pem -text -noout

openssl genrsa -out runai.key 2048
openssl req -new -key runai.key -out runai.csr

rm openssl.cnf
cat << EOF >> openssl.cnf
# Extensions to add to a certificate request
basicConstraints       = CA:FALSE
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName         = @alt_names
[ alt_names ]
DNS.5 = *.apps.81.runai.local
DNS.6 = api.81.runai.local
DNS.7 = *.apps.kirson.runai.local 
DNS.8 = api.kirson.runai.local
DNS.10 = *.runai.haproxy.runai.local
DNS.11 = *.runai.local
EOF


openssl x509 -req  -in runai.csr  -CA rootCA.pem   -CAkey rootCA.key -CAcreateseria  -out runai.crt -days 730 -sha256 -extfile openssl.cnf

 cat runai.crt rootCA.pem > full-chain.pem
openssl verify -CAfile rootCA.pem -verify_hostname  cluster.runai.local runai.crt
openssl verify -CAfile rootCA.pem -verify_hostname  runai.apps.81.runai.local runai.crt


