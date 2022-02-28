
#!/usr/bin/sh 

#expected to to lxd_setup.sh to run before this.

echo "----------------------------------------------------------------------------"
echo "Installing kvm virtualization"
echo "----------------------------------------------------------------------------"
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils 
sudo adduser pank libvirt
sudo adduser pank kvm
#check if kvm installed properly
sudo virsh list --all
sudo chown root:libvirt /dev/kvm

#build image requried for VM'
wget http://cdimage.ubuntu.com/ubuntu-core/20/stable/current/ubuntu-core-20-amd64.img.xz
sudo apt install -y xz-utils qemu
unxz ubuntu-core-20-amd64.img.xz
qemu-img resize -f raw ubuntu-core-20-amd64.img 60G
#install OVMF uEFI boot file, it setups /usr/share/OVMF/OVMF_Code.fd
sudo apt-get install -y ovmf

#https://powersj.io/posts/ubuntu-qemu-cli/ reference for understanding testing VM using qemu
#to test run the VM https://powersj.io/posts/ubuntu-qemu-cli/
#upload ssh key to https://one.ubuntu.com so VM downloaded from ubuntu can autheticate yourself without password
#qemu-system-x86_64 -smp 2 -m 2048 -net nic,model=virtio -net user,hostfwd=tcp::8022-:22,hostfwd=tcp::8090-:80 -nographic -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=ubuntu-core-20-amd64.img,cache=none,format=raw,id=disk1,if=none -device virtio-blk-pci,drive=disk1,bootindex=1 -machine accel=kvm
#ssh <your Ubuntu ONE username>@localhost -p 8022

#convert the updated image to dynamic image for our project
sudo apt install -y qemu-utils
qemu-img convert ubuntu-core-20-amd64.img -O vhdx -o subformat=dynamic ubuntu-core-20-amd64.vhdx

qemu-system-x86_64 -smp 2 -m 2048 -net nic,model=virtio -net user,hostfwd=tcp::8022-:22,hostfwd=tcp::8090-:80 -nographic -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=ubuntu-core-20-amd64.vhdx,cache=none,format=raw,id=disk1,if=none -device virtio-blk-pci,drive=disk1,bootindex=1 -machine accel=kvm
