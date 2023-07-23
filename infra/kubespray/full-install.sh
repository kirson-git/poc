
#!/bin/bash
#Get the source ENV
source ENV-FILE


#clean NFS dir
sudo rm -rf /data/*
#get kubeconfig from kubespray
export KUBECONFIG=/home/kirson/kubespray/inventory/rakuten/artifacts/admin.conf

#Enable all nodes to pull images from quay.rakuten.local using CA
cd ~kirson/kubespray ; ansible-playbook -i inventory/rakuten/hosts.yaml copy-rakuten-ca.yaml -u kirson
# Check if storage class called "nfs-csi" exists
cd /home/kirson/air-gapped-$RUNAI_VERSION/deploy




storage_class="nfs-csi"

# Run the kubectl command to get the list of storage classes and check if "nfs-csi" is present
if kubectl get storageclass | grep -q "$storage_class"; then
    echo "Storage class '$storage_class' exists."
else
    echo "Storage class '$storage_class' does not exist. Installing NFS CSI driver and creating the storage class..."

    # Add the CSI Driver NFS Helm repository
    helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts

    # Install the CSI Driver NFS
    helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.2.0

    # Create the sc.yaml file with the necessary configuration
    cat <<EOF > sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: $storage_class
provisioner: nfs.csi.k8s.io
parameters:
  server: jump.rakuten.local
  share: /data
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4.1
EOF

    # Create the storage class
    kubectl create -f sc.yaml

    # Make the storage class the default
    kubectl patch storageclass "$storage_class" -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

    echo "NFS CSI driver and storage class '$storage_class' installed."
fi


# Check if Prometheus is installed

namespace="monitoring"

# Run the kubectl command to check if Prometheus pods are running in the specified namespace
if kubectl get pods -n "$namespace" | grep -q "prometheus"; then
    echo "Prometheus is installed in the namespace '$namespace'."
else
    echo "Prometheus is not installed in the namespace '$namespace'. Installing Prometheus..."

    # Add the Prometheus Community Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

    # Update the Helm repositories
    helm repo update

    # Install Prometheus using the kube-prometheus-stack chart
    helm install prometheus prometheus-community/kube-prometheus-stack -n "$namespace" --create-namespace --set grafana.enabled=false

    echo "Prometheus installed in the namespace '$namespace'."
fi



# Check if NGINX Ingress Controller is installed

namespace="nginx-ingress"

# Run the kubectl command to check if NGINX Ingress Controller pods are running in the specified namespace
if kubectl get pods -n "$namespace" | grep -q "nginx-ingress"; then
    echo "NGINX Ingress Controller is installed in the namespace '$namespace'."
else
    echo "NGINX Ingress Controller is not installed in the namespace '$namespace'. Installing NGINX Ingress Controller..."

    # Add the NGINX Ingress Helm repository
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    # Update the Helm repositories
    helm repo update

    # Install or upgrade NGINX Ingress Controller using the ingress-nginx chart
    helm upgrade -i nginx-ingress ingress-nginx/ingress-nginx --namespace "$namespace" --create-namespace --set controller.kind=DaemonSet --set controller.service.type=NodePort --set controller.service.nodePorts.https=32734 --set controller.service.nodePorts.http=31722

    echo "NGINX Ingress Controller installed in the namespace '$namespace'."
fi


# Create NameSpace


check_namespace_exists() {
  local namespace="$1"
  kubectl get namespace "$namespace" &> /dev/null
}

create_namespace() {
  local namespace="$1"
  kubectl create namespace "$namespace" &> /dev/null
}

# Check if 'runai' namespace exists
if check_namespace_exists "runai"; then
  echo "Namespace 'runai' already exists."
else
  echo "Creating namespace 'runai'..."
  create_namespace "runai"
  echo "Namespace 'runai' created."
fi

# Check if 'runai-backend' namespace exists
if check_namespace_exists "runai-backend"; then
  echo "Namespace 'runai-backend' already exists."
else
  echo "Creating namespace 'runai-backend'..."
  create_namespace "runai-backend"
  echo "Namespace 'runai-backend' created."
fi

# Create Secret


cat << EOF >  gcr-secret.yaml
apiVersion: v1
data:
  .dockerconfigjson: ewoJImF1dGhzIjogewoJCSJkZWZhdWx0LXJvdXRlLW9wZW5zaGlmdC1pbWFnZS1yZWdpc3RyeS5hcHBzLm9tZXItbGlyYW4tb2NwLTQtMTEtY2x1c3Rlci5ydW5haWxhYnMuY29tIjogewoJCQkiYXV0aCI6ICJhM1ZpWldGa2JXbHVPbk5vWVRJMU5uNTFlRFpyYmpoNFdqUklibGhuVGtWcVp6WlVUM0ZHU2w4NVlsaG9OMmxxUmtGU2EzcFlUbTA0ZWpSdiIKCQl9LAoJCSJkZWZhdWx0LXJvdXRlLW9wZW5zaGlmdC1pbWFnZS1yZWdpc3RyeS5hcHBzLm9wZW5zaGlmdC1raXJzb24tcmVnaXN0cnktY2x1c3Rlci5ydW5haWxhYnMuY29tIjogewoJCQkiYXV0aCI6ICJhM1ZpWldGa2JXbHVPbk5vWVRJMU5uNWljRWcwYVZSemNFSnRSWEkyUkRCVU1YUkRTMjFsVTFsaldFaElRMjFOYkU5Vk5rNXpSbEJXZFc5MyIKCQl9LAoJCSJkZWZhdWx0LXJvdXRlLW9wZW5zaGlmdC1pbWFnZS1yZWdpc3RyeS5hcHBzLnNjYy1raXJzb24tY2x1c3Rlci5ydW5haWxhYnMuY29tIjogewoJCQkiYXV0aCI6ICJhM1ZpWldGa2JXbHVPbk5vWVRJMU5uNDRlR1pwVEdkUlNubGthVmxLT0RVeVZsTTJiMmx0WmxOblREZDRRM0JCUm5sVlZEZHFOVTh5TFY5WiIKCQl9LAoJCSJxdWF5LnJha3V0ZW4ubG9jYWw6ODQ0MyI6IHsKCQkJImF1dGgiOiAiY25WdVlXazZNVEl6TkRVMk56ZzVNQT09IgoJCX0sCgkJInJlZ2lzdHJ5LnJ1bmFpLXBvYy5jb20iOiB7CgkJCSJhdXRoIjogIllXUnRhVzQ2UTJ4dmRXUk9ZWFJwZG1VeU1ESXpJUT09IgoJCX0KCX0KfQ==
kind: Secret
metadata:
  name: gcr-secret
type: kubernetes.io/dockerconfigjson
EOF

# Insert Secret
kubectl apply -f gcr-secret.yaml -n runai-backend
kubectl apply -f gcr-secret.yaml -n runai

# Patch ImagePullSecret

cat << EOF > patch-imagepullsecret
spec:
  template:
    spec:
      imagePullSecrets:
      - name: gcr-secret
EOF



# Create runai-adm - backend value -file
sleep 10

chmod +x runai-adm

./runai-adm generate-values --domain $DOMAIN --tls-cert=rakuten-local.pem --tls-key=rakuten-local.key --registry quay.rakuten.local:8443/air-gapped


#fix NFS StorageClass
sed -i 's/storageClassName: ""/storageClassName: "nfs-csi"/' runai-backend-values.yaml


# Install Back-End


helm install runai-backend runai-backend-$RUNAI_VERSION.tgz -n runai-backend -f runai-backend-values.yaml

# Patch deployments, replicasets, and statefulsets - Add ImagePullSecret
for i in $(kubectl get deployments -n runai-backend | awk '{print $1}' | grep -v "NAME"); do
  kubectl -n runai-backend patch deployment $i --patch-file patch-imagepullsecret
done

for i in $(kubectl get replicasets -n runai-backend | awk '{print $1}' | grep -v "NAME"); do
  kubectl -n runai-backend patch replicasets $i --patch-file patch-imagepullsecret
done

for i in $(kubectl get statefulset -n runai-backend | awk '{print $1}' | grep -v "NAME"); do
  kubectl -n runai-backend patch statefulset $i --patch-file patch-imagepullsecret
done

sleep 3

# Delete pods forcefully
sleep 120
sudo chown 1001:1001 /data/ -R
kubectl -n runai-backend delete pods --all --force
sudo chown 1001:1001 /data/ -R

namespace="runai-backend"

# Function to check if all pods have the "Running" status
check_pods_running() {
  pod_list=$(kubectl get pods -n "$namespace" --no-headers)
  echo "$pod_list" | awk '{if ($3 != "Running") exit 1}'
  return $?
}

# Wait until all pods have the "Running" status
until check_pods_running; do
  echo "Waiting for all pods to have the 'Running' status..."
  sleep 5
done

echo "All pods have the 'Running' status in the $namespace namespace."
sleep 30
#Start the runai-cluster Install
source ENV-FILE
token=$(curl --insecure --location --request POST "https://$DOMAIN/auth/realms/runai/protocol/openid-connect/token" \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode 'grant_type=password' \
        --data-urlencode 'client_id=runai' \
        --data-urlencode 'username=test@run.ai' \
        --data-urlencode 'password=Abcd!234' \
        --data-urlencode 'scope=openid' \
        --data-urlencode 'response_type=id_token' | jq -r .access_token)


uuid=$(curl --insecure -X 'POST' \
        "https://$DOMAIN/v1/k8s/clusters" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer $token" \
        -H 'Content-Type: application/json' \
        -d "{
    \"name\": \""${CLUSTER_NAME}".yaml\",
    \"description\": \"group-a-cluster\"
  }" | jq -r .uuid)
          curl --insecure "https://$DOMAIN/v1/k8s/clusters/$uuid/installfile?cloud=op" \
            -H 'accept: application/json' \
            -H "Authorization: Bearer $token" \
            -H 'Content-Type: application/json' > "${CLUSTER_NAME}"-cluster.yaml

helm upgrade -i runai-cluster -n runai runai-cluster-"${RUNAI_VERSION}".tgz -f "${CLUSTER_NAME}"-cluster.yaml --create-namespace


cat << EOF >> backend-patch
spec:
  template:
    spec:
      volumes:
        - name: config-volume
          configMap:
            name: pull
      containers:
      - name: runai-backend-container
        env:
        - name: NODE_EXTRA_CA_CERTS
          value: /etc/ssl/certs/key.crt
        volumeMounts:
        - mountPath: /etc/ssl/certs/key.crt
          name: config-volume
          readOnly: true
          subPath: key.crt
EOF


cat << EOF > patch-configmap
spec:
  template:
    spec:
      volumes:
        - name: config-volume
          configMap:
              name: dbs-cm
      containers:
        - name: assets-sync
          volumeMounts:
            - name: config-volume
              mountPath: /etc/ssl/certs/
              readOnly: true
EOF

kubectl -n runai create configmap dbs-cm --from-file=dbs.pem
kubectl -n runai patch deployment assets-sync --patch-file patch-configmap
