
#!/usr/bin/sh

echo "----------------------------------------------------------------------------"
echo "Installing docker"
echo "----------------------------------------------------------------------------"

#https://docs.docker.com/engine/install/ubuntu/
echo "----------------------------------------------------------------------------"
echo "docket previous install cleanup"
echo "----------------------------------------------------------------------------"

sudo apt-get remove -y docker docker-engine docker.io containerd runc

echo "----------------------------------------------------------------------------"
echo "Setup Docker Repo..."
echo "----------------------------------------------------------------------------"

#Prep for repo 
#add required docker packages as repo prep
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

#update local repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


echo "----------------------------------------------------------------------------"
echo "Install Docker..."
echo "----------------------------------------------------------------------------"

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io 


echo "----------------------------------------------------------------------------"
echo "Validate Docker Install..."
echo "----------------------------------------------------------------------------"
sudo docker run hello-world

#https://docs.docker.com/engine/install/linux-postinstall/
echo "----------------------------------------------------------------------------"
echo "Setup Linux for Docker..."
echo "----------------------------------------------------------------------------"
#sudo groupadd docker
sudo usermod -aG docker $USER
sleep 10
newgrp docker
#sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
#sudo chmod g+rwx "$HOME/.docker" -R

echo "----------------------------------------------------------------------------"
echo "Validate Docker Install w/o sudo..."
echo "----------------------------------------------------------------------------"
docker run hello-world

