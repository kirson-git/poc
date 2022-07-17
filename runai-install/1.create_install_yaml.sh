#!/bin/bash

echo "Create backend Namespace"
kubectl create namespace runai-backend
sleep 2
echo "Creating backend File"
DOMAIN=livingoptics.runai-23.com
NFS=192.168.133.23
NFS_PATH=/lo
EXT=3.23.99.96
INT=192.168.26.249

sh create-self-signed.sh $DOMAIN
runai-adm generate-values --domain  $DOMAIN --tls-cert  ssl/$DOMAIN/cert.pem \
    --tls-key ssl/$DOMAIN/key.pem --nfs-server $NFS  --nfs-path $NFS_PATH \
    --external-ips $EXT,$INT

sleep 3


kubectl create -f gcr.yaml
#kubectl create -f cert.yaml

echo "Please add Anotation to ingress  "
echo "kubectl edit ingress -n runai-backend runai-backend-ingress"
echo "cert-manager.io/issuer: letsencrypt-prod"

