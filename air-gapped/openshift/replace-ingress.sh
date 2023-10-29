
ROOT=
KEY=
CERT=

kubectl patch proxy/cluster      --type=merge      --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'


oc create configmap custom-ca \
     --from-file=ca-bundle.crt=./rootCA.pem \
     -n openshift-config
Step 2
oc patch proxy/cluster \
( Wait ! check with oc get co )

kubectl patch proxy/cluster      --type=merge      --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'


Step 3
oc create secret tls wild-runai \
     --cert=/alex/runai.crt \
     --key=/alex/runai.key \
     -n openshift-ingress
Step 4
oc patch ingresscontroller.operator default \
     --type=merge -p \
     '{"spec”:{"defaultCertificate": {"name": "wild-runa"}}}' \
     -n openshift-ingress-operator
