
#/usr/bin/sh

sudo apt-get update
#sudo apt-get install software_properties_common
#sudo apt-get update
sudo apt install -y  bash tini libc6 libpam-modules krb5-user libnss3 procps
sudo apt-get install -y openjdk-11-jdk
java -version

sudo apt-get install -y scala
scala -version

sudo apt-get install -y openssh-server openssh-client

#tar -xvzf spark-3.1.2-bin-hadoop3.2.tgz
#sudo mv spark-3.1.2-bin-hadoop3.2 /usr/local/spark

sudo scp -r pank@pphomevm01:/usr/local/spark /usr/local/
