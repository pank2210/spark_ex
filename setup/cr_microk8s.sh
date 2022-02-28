
#!/usr/bin/sh

#Setup ubuntu


#Reference https://ubuntu.com/blog/how-to-run-apache-spark-on-microk8s-and-ubuntu-core-in-the-cloud-part-1

echo "----------------------------------------------------------------------------"
echo "Install VM/snap multipass..."
echo "----------------------------------------------------------------------------"
#install ubuntu Core VM / snap using multipass and lxd

BASE_DIR=/disk1

echo "----------------------------------------------------------------------------"
echo "Install microk8s..."
echo "Creating microk8s container..."
echo "----------------------------------------------------------------------------"
#install K8's microk8s

TARGET_IP=`hostname`
TARGET_USER=pank2210
ssh $TARGET_USER@$TARGET_IP -p 8022 < cmd_lxc_microk8s.txt

