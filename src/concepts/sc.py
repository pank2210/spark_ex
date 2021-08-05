
from pyspark import SparkConf, SparkContext

#conf = SparkConf().setAppName("PySpark App").setMaster("local")
conf = SparkConf().setAppName("PySpark App").setMaster("spark://nodemaster:7077")


sc = SparkContext(conf=conf)

configurations = sc.getConf().getAll()
for conf in configurations:
    print(conf)

