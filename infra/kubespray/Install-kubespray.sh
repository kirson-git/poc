#!/bin/bash

VER=v2.23.0
DIR=runai
IP=192.168.0.99

# Install needed pip
sudo apt install python3 python3-pip -y

# Install Kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git
git checkout $VER
cd kubespray ; cp -pr ./inventory/sample/ ./inventory/$DIR





---
