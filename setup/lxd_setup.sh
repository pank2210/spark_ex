
#!/usr/bin/sh

#Setup ubuntu


#Reference https://ubuntu.com/blog/how-to-run-apache-spark-on-microk8s-and-ubuntu-core-in-the-cloud-part-1

echo "----------------------------------------------------------------------------"
echo "Install VM/snap multipass..."
echo "----------------------------------------------------------------------------"
#install ubuntu Core VM / snap using multipass and lxd

#if failed wait for few seconds between 2 commands
sudo snap install -y multipass
multipass launch -m 12G -d 60G -n ubu-core core18
multipass shell ubu-core
sudo snap install -y lxd

echo "----------------------------------------------------------------------------"
echo "Install microk8s..."
echo "----------------------------------------------------------------------------"
#install K8's microk8s
sudo snap install -y microk8s --classic
sudo usermod -a -G microk8s pank
sudo chown -f -R pank ~/.kube

#install zfs 
echo "----------------------------------------------------------------------------"
echo "Install zfs..."
echo "----------------------------------------------------------------------------"
sudo apt install -y zfsutils-linux
sudo modprobe zfs

#initialize lxd 
echo "----------------------------------------------------------------------------"
echo "Creating zpool..."
echo "----------------------------------------------------------------------------"
#create a zfs pool storage space file
mkdir /disk1/lxd_data
truncate -s 64G /disk1/lxd_data/lxd_zfs_pool.img
sudo zpool create lxd_zfs_pool /disk1/lxd_data/lxd_zfs_pool.img
sudo zpool list
sudo zpool status

echo "----------------------------------------------------------------------------"
echo "runlxd init command setting new storage pool to zfs pool name[lxd_zfs_pool] "
echo "----------------------------------------------------------------------------"
sudo lxd init

echo "----------------------------------------------------------------------------"
echo "Creating microk8s container..."
echo "----------------------------------------------------------------------------"
#set microk8s profile
sudo lxc profile create microk8s
cat microk8s.profile | sudo lxc profile edit microk8s
sudo lxc launch -p default -p microk8s ubuntu:18.04 microk8s
sleep 10
sudo lxc exec microk8s -- sudo snap install microk8s --classic

echo "----------------------------------------------------------------------------"
echo "Updating local for microk8s container..."
echo "----------------------------------------------------------------------------"
sudo lxc shell microk8s

cat > /etc/rc.local <<EOF
#!/bin/bash

apparmor_parser --replace /var/lib/snapd/apparmor/profiles/snap.microk8s.*
exit 0
EOF

chmod +x /etc/rc.local
systemctl restart rc-local

echo 'L /dev/kmsg - - - - /dev/null' > /etc/tmpfiles.d/kmsg.conf
echo '--conntrack-max-per-core=0' >> /var/snap/microk8s/current/args/kube-proxy
exit

sudo lxc restart microk8s
sleep 15
sudo lxc exec microk8s -- sudo swapoff -a


echo "----------------------------------------------------------------------------"
echo "Testing microk8s container..."
echo "----------------------------------------------------------------------------"
sudo lxc exec microk8s -- sudo microk8s.kubectl create deployment microbot --image=dontrebootme/microbot:v1
sudo lxc exec microk8s -- sudo microk8s.kubectl expose deployment microbot --type=NodePort --name=microbot-service --port=80
MICROBOT_PORT=$(sudo lxc exec microk8s -- sudo microk8s.kubectl get all | grep service/microbot | awk '{ print $5 }' | awk -F':' '{ print $2 }' | awk -F'/' '{ print $1 }')
UK8S_IP=$(sudo lxc list microk8s | grep microk8s | awk -F'|' '{ print $4 }' | awk -F' ' '{ print $1 }')

sudo snap install curl
curl http://$UK8S_IP:$MICROBOT_PORT/

echo "----------------------------------------------------------------------------"
echo "Installing kvm virtualization"
echo "----------------------------------------------------------------------------"
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils 
sudo adduser `whoami` libvirt
sudo adduser `whoami` kvm
#check if kvm installed properly
sudo virsh list --all
sudo chown root:libvirt /dev/kvm


