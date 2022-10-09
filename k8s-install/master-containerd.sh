#!/bin/bash

### Step I   - Docker Install ####
echo "Please Enter External IP address "
read EXTERNAL




### Step II   - Install Kuberneters 1.23.5  ####


#!/bin/bash

cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

sudo apt-get update && sudo apt-get install -y containerd



sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

sudo apt-get update 
sudo apt-get install -y kubelet=1.24.6-00 kubeadm=1.24.6-00 kubectl=1.24.6-00
sudo apt-mark hold kubelet kubeadm kubectl
sudo apt install nfs-common
sudo swapoff -a




sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=$EXTERNAL --kubernetes-version=v1.24.6 --token-ttl 180h

mkdir ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config


#kubeadm token create --print-join-command 


wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/3.9.0/helm-linux-amd64.tar.gz
#wget https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
tar zxvf helm-linux-amd64.tar.gz
sudo mv helm-linux-amd64 /usr/local/bin/helm


#Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#Flannel
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
### Use the following to install NVIDIA Operator


#sudo apt install nfs-kernel-server