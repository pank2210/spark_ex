#!/bin/bash 

echo "List HDFS"
hdfs dfs -ls 

USER="hadoop"
TARGET_DIR="data"

echo "creating $TARGET_DIR in HDFS"
hdfs dfs -mkdir -p /user/$USER/$TARGET_DIR

echo "List HDFS"
hdfs dfs -ls $TARGET_DIR/

for FILE in ../../data/*; 
  do 
     echo -e "Sending $FILE to HDFS\!"; 
     hdfs dfs -put -f $FILE /user/$USER/$TARGET_DIR/
  done

echo "List HDFS"
hdfs dfs -ls $TARGET_DIR/
