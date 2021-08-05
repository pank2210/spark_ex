
import os
from pyspark import SparkContext


_words_arr =  ["scala",
   "java", 
   "hadoop", 
   "spark", 
   "akka",
   "spark vs hadoop", 
   "pyspark",
   "pyspark and spark"]

sc = SparkContext("local", "$$$$ RDD Map App1")

words = sc.parallelize( _words_arr)

words_map = words.map( lambda x: (x,1))
maped_rdd = words_map.collect()

print("#### Key value pair -> %s" % (maped_rdd))
