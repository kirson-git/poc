oc create configmap custom-ca \
     --from-file=ca-bundle.crt=rootCA.pem \
     -n openshift-config


 oc patch proxy/cluster \
  --type=merge \
  --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'


oc create secret tls ocp-wild \
  --cert=./full-chain.pem \
  --key=./runai.key  \
  -n openshift-ingress


 oc patch ingresscontroller.operator default \
  --type=merge -p \
  '{"spec":{"defaultCertificate": {"name": "ocp-wild"}}}' \
   -n openshift-ingress-operator
