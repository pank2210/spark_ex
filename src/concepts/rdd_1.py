
import os
from pyspark import SparkContext


logFile = "README.md"
sc = SparkContext("local", "$$$$ Simple RDD App1")
rdd_tf = sc.textFile(os.path.join("/user/hadoop/test/", logFile)).cache()
numAs = rdd_tf.filter(lambda s: 'a' in s).count()
numBs = rdd_tf.filter(lambda s: 'b' in s).count()
print("#### Lines with a: %i, lines with b: %i" % (numAs, numBs))
