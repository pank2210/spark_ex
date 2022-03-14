

#!/usr/bin/sh

TEMP_DIR="/tmp"
WORK_DIR="/disk1/opt"

if [ ! -d $WORK_DIR ] 
then
	echo "Create WORK_DIR[$WORK_DIR]"
	mkdir -p $WORK_DIR
fi

JAVA_VERSION=11
echo "-----------------------------------------------------------"
echo "Setting up Java Version[$JAVA_VERSION]"
sudo apt-get install -y openjdk-$JAVA_VERSION-jre
JAVA_PATH=`update-java-alternatives --list |  awk '{print $3}' | grep $JAVA_VERSION`
echo "Java Path setting to [$JAVA_PATH]"
sudo update-java-alternatives --set $JAVA_PATH
export JAVA_HOME=$JAVA_PATH

FLINK_VERSION=1.14.4
SCALA_VERSION=2.11
echo "-----------------------------------------------------------"
echo "Setting up Flink version[$FLINK_VERSION] and Scala[$SCALA_VERSION]"
cd $TEMP_DIR
FLINK_TARFILE="flink-$FLINK_VERSION-bin-scala_$SCALA_VERSION.tgz"
if [ ! -f $TEMP_DIR/$FLINK_TARFILE ]
then
   echo "Downloading File[$FLINK_TARFILE]"
   wget http://mirrors.estointernet.in/apache/flink/flink-$FLINK_VERSION/$FLINK_TARFILE
   if [ ! $? -eq 0 ]
   then
      echo "Error: Downloading File[$FLINK_TARFILE] "
      exit -1
   fi
fi
cd $WORK_DIR
if [ ! -d $WORK_DIR/flink-$FLINK_VERSION ]
then
   tar -xzf $TEMP_DIR/$FLINK_TARFILE
fi

echo "-----------------------------------------------------------"
echo "Starting Flink Cluster"
$WORK_DIR/flink-$FLINK_VERSION/bin/start-cluster.sh
