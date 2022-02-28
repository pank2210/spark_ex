
#!/usr/bash

echo "----------------------------------------------------------------------------"
echo "Seting up DockerFile for Spark/hadoop..."
echo "Call this script with argument of spark version and hadoop version"
echo "----------------------------------------------------------------------------"

SPARK_VER=$1
HADOOP_VER=$2
WORKING_DIR=/tmp/spark

[ ! -d $WORKING_DIR ] && mkdir $WORKING_DIR
cd $WORKING_DIR

INSTALLER_FILE="spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz"
echo "Checking or processing [$INSTALLER_FILE]"

[ ! -f $INSTALLER_FILE ] && wget https://archive.apache.org/dist/spark/spark-$SPARK_VER/$INSTALLER_FILE
if [ $? -ne 0  -a ! -f $INSTALLER_FILE ]
then
	echo "wget failed for SPARK_VER=$SPARK_VER and HADOOP_VER=$HADOOP_VER"
	echo "USAGE: $0 <SPARK_VERSION> <HADOOP_VER>"
	exit -1
fi

tar xzf spark-3.1.2-bin-hadoop3.2.tgz
cd spark-3.1.2-bin-hadoop3.2

cat << EOF > Dockerfile 
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM ubuntu:20.04

ARG spark_uid=185

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:latest -f kubernetes/dockerfiles/spark/Dockerfile .
ENV DEBIAN_FRONTEND noninteractive

RUN set -ex && \
    sed -i 's/http:\/\/deb.\(.*\)/https:\/\/deb.\1/g' /etc/apt/sources.list && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y python3 python3-pip openjdk-11-jre-headless bash tini libc6 libpam-modules krb5-user libnss3 procps && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/examples && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

COPY jars /opt/spark/jars
COPY bin /opt/spark/bin
COPY sbin /opt/spark/sbin
COPY kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY kubernetes/dockerfiles/spark/decom.sh /opt/
COPY examples /opt/spark/examples
COPY kubernetes/tests /opt/spark/tests
COPY data /opt/spark/data

RUN pip install pyspark
RUN pip install findspark

ENV SPARK_HOME /opt/spark

WORKDIR /opt/spark/work-dir
RUN chmod g+w /opt/spark/work-dir
RUN chmod a+x /opt/decom.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Specify the User that the actual main process will run as
USER ${spark_uid}
EOF