#!/bin/bash

# Install CRI-O prerequisites
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24/CentOS_8/devel:kubic:libcontainers:stable:cri-o:1.24.repo
sudo yum update -y
sudo yum install -y cri-o

# Enable and start CRI-O
sudo systemctl enable --now crio

# Install Kubernetes prerequisites
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo yum install -y kubelet-1.24.0-0 kubeadm-1.24.0-0 kubectl-1.24.0-0 --disableexcludes=kubernetes

# Start and enable Docker and Kubernetes
sudo systemctl enable --now docker
sudo systemctl enable --now kubelet

# Initialize Kubernetes
sudo kubeadm init --cri-socket=/var/run/crio/crio.sock

# Configure kubectl for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply CNI network plugin
sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

