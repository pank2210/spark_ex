
#/usr/bin/sh

#tar -xvzf spark-3.1.2-bin-hadoop3.2.tgz
#sudo mv spark-3.1.2-bin-hadoop3.2 /usr/local/spark

#scope of this script is purely for repplicating master node setup into worked node
#All network connectivity from master to all nodes i.e. ssh w/ no password is done
#set up expect one master and multiple cluster nodes, this script is use to setup worker or slaves
#set some custom variables for locl script use
#before this script is run it is expected that some of recommended,
#setup of requried version of hadoop and spark is donwloaded and unzip into /usr/local/
#And then the setting in hadoop/spark are implemented as per guidelines in reference. i.e. udpate of *-site.xml
#it is expected that a custom /data directory is also created for setup

PROFILE=.bashrc
HADOOP_HOME=/usr/local/hadoop
SPARK_HOME=/usr/local/spark
DATA=/data


#pphomevm01 is hostname of master node and slaves will have same configured 
sudo scp -r pank@pphomevm01:/usr/local/hadoop /usr/local/
sudo scp -r pank@pphomevm01:/usr/local/spark /usr/local/
sudo chown -R pank:root $HADOOP_HOME
sudo chown -R pank:root $SPARK_HOME
sudo chown -R pank:root $DATA
if [[ ! -d $DATA/hadoop ]] 
then
  mkdir -p $DATA/hadoop 
fi
sudo chown -R pank:root $DATA/hadoop

echo "#############################################" >> $HOME/$PROFILE
echo "#Settings for hadoop admin setup user profile." >> $HOME/$PROFILE
echo "#############################################" >> $HOME/$PROFILE
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> $HOME/$PROFILE
echo "export HADOOP_HOME=$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_INSTALL=\$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_YARN_HOME=\$HADOOP_HOME" >> $HOME/$PROFILE
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> $HOME/$PROFILE
echo "export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin" >> $HOME/$PROFILE
echo "export HADOOP_OPTS="-Djava.library.path=\$HADOOP_HOME/lib/native"" >> $HOME/$PROFILE

echo "#############################################" >> $HOME/$PROFILE
echo "#Settings for spark admin setup user profile." >> $HOME/$PROFILE
echo "#############################################" >> $HOME/$PROFILE
echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> $HOME/$PROFILE
echo "export SPARK_HOME=$SPARK_HOME" >> $HOME/$PROFILE
echo "export PATH=\$PATH:\$SPARK_HOME/sbin:\$SPARK_HOME/bin" >> $HOME/$PROFILE
echo "export LD_LIBRARY_PATH=\$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH" >> $HOME/$PROFILE

#echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
