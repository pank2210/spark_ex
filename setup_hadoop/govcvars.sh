export ESXI_SERVER_IP=192.168.0.113 # vCenter IP/FQDN
export GOVC_INSECURE=1 # Don't verify SSL certs on vCenter
export GOVC_URL=${ESXI_SERVER_IP} # vCenter IP/FQDN
export GOVC_USERNAME=root #@${ESXI_SERVER_IP} # vCenter username
export GOVC_PASSWORD=Apple123@ # vCenter password
export GOVC_DATASTORE=datastore1 # Default datastore to deploy to
export GOVC_NETWORK="VM Network" # Default network to deploy to
export GOVC_RESOURCE_POOL='*/Resources' # Default resource pool to deploy to
