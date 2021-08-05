from pyspark import SparkContext
from pyspark import SparkFiles

finddistance = "/home/hadoop/spark/README.md"
finddistance = "/home/hadoop/dev/spark/rdd_1.py"
finddistancename = "rdd_1.py"
sc = SparkContext("local", "SparkFile App")
sc.addFile(finddistance)

print "Absolute Path -> %s" % SparkFiles.get(finddistancename)
