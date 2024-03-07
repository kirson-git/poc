sudo apt install python3 python3-pip
sudo pip3 install --upgrade pip
sudo pip3 install -r requirements.txt
cp -pr ./inventory/sample ./inventory/runai


declare -a IPS=(master-0,192.168.10.220,worker-1,192.168.10.230 ,worker-2,192.168.10.231)

CONFIG_FILE=inventory/runai/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

ssh-keygen
ssh-copy-id to all servers


vi iventory/runai/group_vars/k8s_cluster/addons.yml
vi inventory/runai/group_vars/k8s_cluster/k8s-cluster.yaml
kube_version: v1.25.6
kube_network_plugin: calico
container_manager: containerd
kubeconfig_localhost: true
kubectl_localhost: true
enable_nodelocaldns: false



#test
ansible -i ./inventory/runai/hosts.yaml all -b -u kirson -m ping| grep -i SUC

#install
ansible-playbook -i inventory/runai/hosts.yaml cluster.yml -u kirson -b


