DOMAIN=your-fqdn
CERT=path-to-crt
KEY=path-to-key
USER=use-name
PASSWD=password 
### Create Storage Path
mkdir /quay-storage/
/mirror-registry install --sslCert $CERT --sslkey $KEY   --targetHostname $DOMAIN  --initUser=$USER --initPassword=$PASSWD  --pgStorage /quay-storage/ --quayStorage /quay-storage/ --quayRoot /quay-storage/ -v
