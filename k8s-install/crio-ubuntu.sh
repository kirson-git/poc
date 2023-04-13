#!/bin/bash

# Install CRI-O prerequisites
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:projectatomic/ppa
sudo apt-get update
sudo apt-get install -y cri-o-1.24

# Install Kubernetes prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# Install Kubernetes
sudo apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# Configure CRI-O
sudo mkdir -p /etc/systemd/system/crio.service.d
cat <<EOF | sudo tee /etc/systemd/system/crio.service.d/override.conf
[Service]
ExecStartPre=/usr/libexec/crio-nsenter
EOF

# Start and enable CRI-O
sudo systemctl daemon-reload
sudo systemctl start crio
sudo systemctl enable crio

# Initialize Kubernetes
sudo kubeadm init --cri-socket=/var/run/crio/crio.sock

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply CNI network plugin
sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

