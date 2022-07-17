#!/bin/bash
echo "Downloading runai-adm for Linux"
wget --content-disposition https://app.run.ai/v1/k8s/admin-cli/linux
chmod +x runai-adm
sudo mv runai-adm /usr/local/bin/runai-adm


echo "Download HELM3 "
wget https://get.helm.sh/helm-v3.9.1-linux-amd64.tar.gz
chmod +x linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm

