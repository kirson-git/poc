#!/bin/bash
set -e # this will make the script stop on the first error
set -u # this will make the script stop if there is an undefined variable

# Generate the root key with the provided passphrase
openssl genrsa -des3 -passout pass:YourPassphrase -out rootCA.key 2048

# Generate root certificate
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 730 -out rootCA.pem \
    -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=rootca.local"

# Display the certificate
openssl x509 -in rootCA.pem -text -noout

# Generate a private key for your service
openssl genrsa -out runai.key 2048

# Generate a CSR for your service. Adjust the subject fields as needed.
openssl req -new -key runai.key -out runai.csr \
    -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=runai.local"

# Create the configuration file for the extensions
cat << EOF > openssl.cnf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
# empty; we are providing this information in the -subj option of the req command

[v3_req]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.apps.81.runai.local
DNS.2 = api.81.runai.local
DNS.3 = *.apps.kirson.runai.local
DNS.4 = api.kirson.runai.local
DNS.5 = *.runai.haproxy.runai.local
DNS.6 = *.runai.local
EOF

# Create the certificate using the CSR, the CA private key, the CA certificate, and the provided extensions
openssl x509 -req -in runai.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial \
    -out runai.crt -days 730 -sha256 -extfile openssl.cnf 


# Combine the certificates into a chain
cat runai.crt rootCA.pem > full-chain.pem

# Verify the certificates (adjust your domain names accordingly)
openssl verify -CAfile rootCA.pem -verify_hostname cluster.runai.local runai.crt
openssl verify -CAfile rootCA.pem -verify_hostname runai.apps.81.runai.local runai.crt

