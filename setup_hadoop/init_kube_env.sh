# Turn off swap
swapoff -a
sed -i -r 's/(\/swap.+)/#\1/' /etc/fstab
 
# Docker CE
apt update
apt upgrade -y
apt install ca-certificates software-properties-common apt-transport-https curl -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt install docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) -y
tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
 
mkdir -p /etc/systemd/system/docker.service.d && systemctl daemon-reload && systemctl restart docker
docker info | egrep "Server Version|Cgroup Driver"
 
# Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
tee /etc/apt/sources.list.d/kubernetes.list >/dev/null <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt update
apt install -y kubeadm=1.19.0-00 kubelet=1.19.0-00 kubectl=1.19.0-00
apt-mark hold kubelet kubeadm kubectl
tee /etc/sysctl.d/k8s.conf >/dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
EOF
sysctl --system
 
# vm tools
# A number of CNI implementations (such Calico, Antrea, and etc) introduce networking artifacts that interfere with 
# the normal operation of vSphere's internal reporting for network/device interfaces.
# To address this issue, an exclude-nics filter for VMTools needs to be applied in order to prevent
# these artifacts from getting reported to vSphere and causing problems with network/device associations to vNICs on virtual machines.
# see https://github.com/kubernetes/cloud-provider-vsphere/blob/master/docs/book/known_issues.md
 
tee -a /etc/vmware-tools/tools.conf >/dev/null <<EOF
 
[guestinfo]
primary-nics=eth0
exclude-nics=antrea-*,cali*,ovs-system,br*,flannel*,veth*,docker*,virbr*,vxlan_sys_*,genev_sys_*,gre_sys_*,stt_sys_*,????????-??????
EOF
 
systemctl restart vmtoolsd
