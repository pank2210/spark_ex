
import os
from pyspark import SparkContext
from pyspark.sql import SparkSession


_words_arr =  ["scala",
   "java", 
   "hadoop", 
   "pyspark",
   "spark", 
   "pyspark",
   "spark", 
   "spark", 
   "pyspark",
   "java", 
   "akka",
   "spark vs hadoop", 
   "java", 
   "java", 
   "java", 
   "pyspark",
   "java", 
   "pyspark and spark"]

spark  = SparkSession.builder\
                  .master("local")\
                  .enableHiveSupport()\
                  .getOrCreate()

sc = spark.sparkContext

words = sc.parallelize( _words_arr)

res = words.map( lambda x: (x,1))
res = res.sortByKey()
res = res.reduceByKey(lambda a,b: a+b)
maped_rdd = res.collect()

print("#### Key value pair -> %s" % (maped_rdd))
