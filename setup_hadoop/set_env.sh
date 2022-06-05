

JAVA_PATH=`update-java-alternatives --list |  awk '{print $3}' | grep $JAVA_VERSION`
echo "Java Path setting to [$JAVA_PATH]"
sudo update-java-alternatives --set $JAVA_PATH
export JAVA_HOME=$JAVA_PATH
