# Streaming Kafka Example - Interactive Session



## Data Structure ##

Key-Value pairs:  
- `t`=*n*
- `v`=*val*

*t* is the timestamp 1,2,....n  
*v* is a value recorded for timestamp "*t*".  


## Test Case ##

Generate a rolling view of average *v* over a window of 5 timestamp periods - i.e. delta *t* = 5

## Create Sample Data ##

Pre-Reqs:
1. Start Zookeeper
2. Start Kafka Server.  These examples assume it is available on port 9092

#### Setup Topic

./bin/kafka-topics.sh --create --topic window-example --bootstrap-server localhost:9092

#### Start a Producer

 
./bin/kafka-console-producer.sh --topic window-example --bootstrap-server localhost:9092 

#### Start the sample Pyspark Query

From the jupyterlab docker container in /opt/workspace/notebooks/jobs, use spark-submit.sh script to submit the kafka-example.py pyspark script 

docker exec -it jupyterlab bash

cd /opt/workspace/notebooks/jobs

 ./spark-submit.sh kafka-example.py
 
#### Enter test data in the Kafka producer

Enter key-value strings separated by new-line (just hit enter).  These are parsed by kafka-example.py

EG

1,3
1,4
2,2
2,1
2,3
2,1
3,4
3,5
3,6
1,10

#### Check the output of the Spark jobs


kafka-example.py should process the events and periodically update the summary results based on the sum-by-key for all values as new key-value pairs are entered into the producer.


-------------------------------------------
Batch: 0
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
+--------+---------------+

-------------------------------------------
Batch: 1
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|1       |3.0            |
+--------+---------------+

-------------------------------------------
Batch: 2
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|1       |7.0            |
+--------+---------------+

-------------------------------------------
Batch: 3
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|1       |7.0            |
|2       |2.0            |
+--------+---------------+

-------------------------------------------
Batch: 4
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|1       |7.0            |
|2       |3.0            |
+--------+---------------+

-------------------------------------------
Batch: 5
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|1       |7.0            |
|2       |6.0            |
+--------+---------------+

-------------------------------------------
Batch: 6
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|3       |4.0            |
|1       |7.0            |
|2       |6.0            |
+--------+---------------+

-------------------------------------------
Batch: 7
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|3       |10.0           |
|1       |7.0            |
|2       |6.0            |
+--------+---------------+

-------------------------------------------
Batch: 8
-------------------------------------------
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
|3       |10.0           |
|1       |17.0           |
|2       |6.0            |
+--------+---------------+




