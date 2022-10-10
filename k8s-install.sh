#!/bin/bash

#export PROD=prod-kubeconfig
#export DR=dr-kubeconfig
export EXTERNAL="$2"
#export KUBECONFIG=$PROD
usage() {

    echo " ----------------------------- ---------------------------------------------------------- "
    echo " ----------------------------- ---------------------------------------------------------- "
    echo " ---- Use the following script to Install Kubernetes for  ---- "
    echo " ----------------------------- ---------------------------------------------------------- "
    echo " * 1.24.6 : Installs Kubernetes 1.24.6 with containerd & Calico"
    echo " * 1.23.5 : Install  Kubernetes 1.23.5 with docker & Flannel"
    echo -e " Usage: $0 [1.24.6   | 1.23.5 ] & external IP address"
    echo "  "
    echo " ---- Ends Descrtipion ---- "
    echo "  "
}


 runai-que (){
    PENDING=$(runai list jobs -A | grep Pen | wc -l)
    echo "Current Status: There is  $PENDING Pending Jobs in the the que"
}


 1.24.6 (){
    

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
}
 cloud (){
   echo "Bursting to Cloud GPU......"
   sleep 4
   export KUBECONFIG=$DR
   kubectl get nodes 

}

key="$1"
case $key in
    1.24.6)
        1.24.6
        ;;
    1.23.5)
        1.23.5
        ;;
    check-version)
        check-version
        ;;
    *)
        usage
        ;;
esac
