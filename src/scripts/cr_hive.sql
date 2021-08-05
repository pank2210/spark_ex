
--script is used as param to hive command to create required hive db and tables

--Create DB
CREATE DATABASE IF NOT EXISTS TESTDB;
SHOW DATABASES;

--Create tables and indexs
DROP INDEX IF EXISTS IND_RAW_TAXI_TRIPS ON RAW_TAXI_TRIPS;
DROP TABLE IF EXISTS RAW_TAXI_TRIPS;
CREATE TABLE IF NOT EXISTS RAW_TAXI_TRIPS(Pickup_DateTime TIMESTAMP, DropOff_datetime TIMESTAMP, PUlocationID INT, DOlocationID INT, SR_Flag INT, Dispatching_base_number STRING, Dispatching_base_num STRING) STORED AS PARQUET;
CREATE INDEX IND_RAW_TAXI_TRIPS ON TABLE RAW_TAXI_TRIPS (Pickup_DateTime,DropOff_datetime);

/*
root
 |-- Pickup_DateTime: timestamp (nullable = true)
 |-- DropOff_datetime: timestamp (nullable = true)
 |-- PUlocationID: integer (nullable = true)
 |-- DOlocationID: integer (nullable = true)
 |-- TimeTaken: long (nullable = true)
 |-- Hour: integer (nullable = true)

*/

--CREATE TABLE IF NOT EXISTS TAXI_TRIPS_STD(Pickup_DateTime TIMESTAMP, DropOff_datetime TIMESTAMP, PUlocationID INT, DOlocationID INT, TimeTaken LONG, Hour INT) STORED AS PARQUET;
--CREATE INDEX IND_TAXI_TRIPS ON TABLE TAXI_TRIPS_STD (Pickup_DateTime,DropOff_datetime);

/*
('############## before aggregate type - ', <class 'pyspark.sql.dataframe.DataFrame'>)
root
 |-- Hour: integer (nullable = true)
 |-- TotalTravelTime: long (nullable = true)
 |-- TotalTrips: long (nullable = false)
 |-- AvgTravelTime: double (nullable = true)
 |-- MinTravelTime: long (nullable = true)
 |-- MaxTravelTime: long (nullable = true)
*/

--CREATE TABLE IF NOT EXISTS TAXI_TRIPS_BY_HOUR( Hour INT, TotalTravelTime LONG, TotalTrips LONG, AvgTravelTime DOUBLE, MinTravelTime LONG, MaxTravelTime LONG) STORED AS PARQUET;
--CREATE INDEX IND_TAXI_TRIPS_BY_HOUR ON TABLE TAXI_TRIPS_BY_HOUR (Hour);
--ALTER TABLE 

--SHOW TABLES;
