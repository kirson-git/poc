


oc create configmap custom-ca  --from-file=ca-bundle.crt=./rootCA.pem   -n openshift-config
oc patch proxy/cluster      --type=merge      --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'
oc create secret tls wild-runai --cert=runai.crt  --key=runai.key  -n openshift-ingress
oc patch ingresscontroller.operator default      --type=merge -p  '{"spec”:{"defaultCertificate": {"name": "wild-runai"}}}'   -n openshift-ingress-operator
