helm install harbor oharbor/harbor \
--set expose.type=ingress \
--set expose.tls.enabled=true \
--set expose.tls.secretName=my-tls-secret \
--set expose.tls.certManager=false \
--set expose.ingress.hosts.core=reg.runai.local \
--set expose.ingress.hosts.notary=notray.runai.local \
--set expose.ingress.annotations."kubernetes\.io/ingress\.class"=nginx \
--set persistence.persistentVolumeClaim.registry.storageClass=nfs-csi \ 
--set persistence.persistentVolumeClaim.chartmuseum.storageClass=nfs-csi \
--set persistence.persistentVolumeClaim.jobservice.storageClass=nfs-csi \
--set persistence.persistentVolumeClaim.registry.accessMode=ReadWriteMany \
--set persistence.persistentVolumeClaim.registry.size=50Gi \
--set persistence.persistentVolumeClaim.chartmuseum.size=5Gi \
--set persistence.persistentVolumeClaim.database.size=5Gi \
--set externalURL=https://reg.runai.local \
--set expose.ingress.hosts.core=reg.runai.local \
--set expose.ingress.hosts.notary=notary.runai.local \
--set harborAdminPassword=admin  \
-n harbor


