#!/bin/bash

### Step I   - Docker Install ####
echo "Please Enter External IP address "
read EXTERNAL

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo sh -c 'cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF'
sudo systemctl restart docker


### Step II   - Install Kuberneters 1.23.5  ####

sudo sh -c 'cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF'

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet=1.23.5-00 kubeadm=1.23.5-00 kubectl=1.23.5-00

sudo swapoff -a
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=$EXTERNAL --kubernetes-version=v1.23.5 --token-ttl 180h

mkdir .kube
sudo cp -i /etc/kubernetes/admin.conf .kube/config
sudo chown $(id -u):$(id -g) .kube/config


#kubeadm token create --print-join-command 


wget https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
tar zxvf helm-v3.9.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
### Use the following to install NVIDIA Operator
#helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update

