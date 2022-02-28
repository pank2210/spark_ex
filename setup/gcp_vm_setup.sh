
#!/usr/bin/sh  

#expected to to gen_vhdx.sh to run before this.

echo "----------------------------------------------------------------------------"
echo "Installing GCP VM using vhdx that was created in previous step by gen_vhdx.sh"
echo "----------------------------------------------------------------------------"

#import the VM image to GCP now

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-352.0.0-linux-x86_64.tar.gz

tar xzf google-cloud-sdk-352.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh

#set JSON secrete key for avoiding individual logins.
#before running this set $GCP_PROECT, GCP_BUCKET ENV variable with requried values
gcloud auth login
gcloud config set project $GCP_PROJECT

gsutil cp ubuntu-core-20-amd64.vhdx gs://$GCP_BUCKET/
gcloud compute images import ubuntu-core-20 --data-disk --source-file=gs://<YOUR_BUCKET>/ubuntu-core-20-amd64.vhdx


#enable secure boot with uEFI flag enabled
gcloud compute images create ubuntu-core-20-secureboot --source-disk ubuntu-core-20 --guest-os-features="UEFI_COMPATIBLE"

#launch that Ubuntu Core VM on the cloud. The command enables nested virtualisation, and it’s going to launch an 8-core, 32GB-RAM N2-series instance with secure boot and a second 60GB block device for LXD.
gcloud beta compute instances create ubuntu-core-20 --zone=europe-west1-b --machine-type=n2-standard-8 --network-interface network=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=<YOUR_SERVICE_ACCOUNT>@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --min-cpu-platform="Intel Cascade Lake" --image=ubuntu-core-20-secureboot --boot-disk-size=60GB --boot-disk-type=pd-balanced --boot-disk-device-name=ubuntu-core-20 --shielded-secure-boot --no-shielded-vtpm --no-shielded-integrity-monitoring --reservation-affinity=any --enable-nested-virtualization --create-disk=size=60,mode=rw,auto-delete=yes,name=storage-disk,device-name=storage-disk

#we can ssh to it in the cloud using the keypair we associated with our Ubuntu ONE account
GCE_IIP=$(gcloud compute instances list | grep ubuntu-core-20 | awk '{ print $5 }')
ssh <your Ubuntu ONE username>@$GCE_IIP
sudo lxd init --auto --storage-create-device=/dev/sdb --storage-backend=zfs
sudo lxc init ubuntu:focal microk8s --vm -c limits.memory=28GB -c limits.cpu=7
sudo lxc config device override microk8s root size=40GB
sudo lxc start microk8s
sleep 90 # give the instance time to boot
sudo lxc exec microk8s -- sudo snap install microk8s --classic
sudo lxc exec microk8s -- sudo microk8s enable storage registry dns ingress


