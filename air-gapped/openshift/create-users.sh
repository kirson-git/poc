htpasswd -c -B -b users.htpasswd kirson kirson
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
cat << EOF >> auth.cr
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider
    challenge: true
    login: true
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
EOF


