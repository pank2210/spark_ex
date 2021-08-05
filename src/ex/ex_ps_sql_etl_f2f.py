
import os
import pickle

from pyspark.sql.functions import year, month, dayofmonth
from pyspark.sql import SparkSession
from pyspark import SparkContext
from datetime import date, timedelta
from pyspark.sql.types import IntegerType, DateType, StringType, StructType, StructField

from pyspark.sql.functions import *

#set url to spark master node and App name
appName = "ex_ps_sql_etl_f2f"
master = "spark://nodemaster:7077"
i_filename = 'fhv_tripdata_2018-01'
i_path = 'data/'
o_path = 'data/results/' + appName

# Create Spark session with Hive supported.
spark = SparkSession.builder \
    .appName(appName) \
    .master(master) \
    .getOrCreate()

#set schema to be used as string. Schema is required to assign right data type for each column.
#inferSchema=True does immediate read when data is loaded by PArtitions Vs giving schema as string is lazy read.
_schema = 'Pickup_DateTime TIMESTAMP, DropOff_datetime TIMESTAMP, PUlocationID INT, DOlocationID INT, SR_Flag INT, Dispatching_base_number STRING, Dispatching_base_num STRING'

#Read data from hdfs in DF and it automatically uses all partitions
#df = spark.read.csv("hdfs://nodemaster:9000/data/fhv_tripdata_2018-01.csv")
#df = spark.read.csv("data/fhv_tripdata_2018-01.csv",inferSchema=True,header=True)
df = spark.read.csv( i_path + i_filename + '.csv', header=True, schema=_schema, sep=',', dateFormat='MM/dd/yyyy', timestampFormat='yyyy-MM-dd HH:mm:ss')
print("############## #no of partitions - ",df.rdd.getNumPartitions())
print("############## df.dtypes - ",df.dtypes)
print("############## before transform type - ",type(df))

#########################################################################
#All transformation begins here
#########################################################################
#execute column drop
df = df.drop('SR_Flag','Dispatching_base_number','Dispatching_base_num')

#execute filter
df = df.filter(~df['PUlocationID'].isNull() | ~df['DOlocationID'].isNull()) #filter all location with null values
#df['TimeTaken'] = df['DropOff_DateTime'] - df['Pickup_DateTime']

#get time diff and pull day and month
df = df.withColumn( 'TimeTaken', col('DropOff_DateTime').cast('long') - col('Pickup_DateTime').cast('long'))
df = df.withColumn( 'Hour', hour(col('DropOff_DateTime')))
#df = df.withColumn( 'month', month(col('DropOff_DateTime')))
print("############## updated df.dtypes - ",df.printSchema())
print("############## before filter type - ",type(df))

#execute filter 2
travelTimeThreshold = long(120) #seconds
df = df.filter(df['TimeTaken'] > travelTimeThreshold)
df = df.sample(fraction=.1,seed=101) #remove this sampling for using full dataset
print("############## updated df.dtypes - ",df.printSchema())
print("############## before aggregate type - ",type(df))

#aggregate and sort

df = df.groupby("Hour") \
        .agg(sum("TimeTaken").alias("TotalTravelTime") \
             ,count("TimeTaken").alias("TotalTrips") \
             ,round(mean("TimeTaken"),2).alias("AvgTravelTime") \
             ,min("TimeTaken").alias("MinTravelTime") \
             ,max("TimeTaken").alias("MaxTravelTime")) \
        .sort("Hour")
print("############## updated df.dtypes - ",df.printSchema())
print("############## before list to DF type - ",type(df))

#########################################################################
#All transformation ends here
#########################################################################

#offload transform data to HDFS using each active partition
outputFileName = o_path
df.write \
    .format("com.databricks.spark.csv") \
    .option("header", "false") \
    .mode("overwrite") \
    .save(outputFileName)

#Optionally collect all results and dump into local text file in /tmp
df = df.collect()
print("############## 1st row - ",df[0])
print("Entire DF - ",df)
print("############## before writing type - ",type(df))

#_df = spark.createDataFrame(df)
#_df.show(25)

#accumulate
arr = []
def add_arr(row):
    arr.append(row.asDict())

#iterate results from each partition
for row in df:
    add_arr(row)

#dump it as python array using pickle
with open('/tmp/' + i_filename + '.pkl','wb') as o_fd:
    pickle.dump(arr,o_fd)

