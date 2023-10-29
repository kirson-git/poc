kubectl patch storageclass nfs-csi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl patch ingress <ingress-name> -n <namespace> --type=merge -p '{"metadata":{"annotations":{"kubernetes.io/ingress.class": "nginx"}}}'

kubectl -n harbor create secret tls harbor-ingress --key  /home/kirson/poc/air-gapped/certs/runai.key --cert /home/kirson/poc/air-gapped/certs/runai.crt
secret/harbor-ingress created

mkdir -p /etc/docker/certs.d/harbor.runai.local
cp rootCA.pem /etc/docker/certs.d/harbor.runai.local/ca.crt
systemctl restart docker

