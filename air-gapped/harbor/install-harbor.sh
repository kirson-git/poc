helm install harbor harbor/harbor \
--set expose.type=ingress \
--set expose.tls.enabled=true \
--set expose.tls.secretName=my-tls-secret \
--set expose.tls.certManager=false \
--set expose.ingress.hosts.core=harbor.runai.local \
--set expose.ingress.hosts.notary=notray.runai.local \
--set expose.ingress.annotations."kubernetes\.io/ingress\.class"=nginx \
--set persistence.persistentVolumeClaim.registry.accessMode=ReadWriteMany \
--set persistence.persistentVolumeClaim.registry.size=50Gi \
--set persistence.persistentVolumeClaim.chartmuseum.size=5Gi \
--set persistence.persistentVolumeClaim.database.size=5Gi \
--set externalURL=https://harbor.runai.local \
--set expose.ingress.hosts.core=harbor.runai.local \
--set expose.ingress.hosts.notary=notary.runai.local \
--set harborAdminPassword=admin  \
-n harbor
