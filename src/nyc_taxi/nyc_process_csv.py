
import os

from pyspark import SparkContext
from pyspark.sql import SparkSession

class process_csv:
   
  def get_spark_session(self): 
    spark  = SparkSession.builder\
       .master("local")\
       .enableHiveSupport()\
       .getOrCreate()
     
    return spark
   
  def load_csv(self,fpath): 
    df = self.spark.read.format("org.apache.spark.sql.csv")\
       .load(fpath)
    df.printSchema()
   
  def __init__(self,idir,fname):
    fpath = os.path.join( idir, fname)
     
    self.spark = self.get_spark_session()
    self.load_csv(fpath)


if __name__ == "__main__":
  idir = "/tmp/"
  fname = "test_data.csv"
  p = process_csv(idir,fname)
