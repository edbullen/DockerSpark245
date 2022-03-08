# Streaming Kafka Example 

This is an interactive example showing a simple aggregation being applied in Spark Streaming based on a stream of data being received from a Kafka topic.

## Data Structure ##

The sample data for this example is a simple list of strings, with each record separated by a new line.  

The string data is structured as key-value pairs by comma-separating the key and value in the string:

```
key_1,value_1
key_2,value_2
...
key_n,value_n
```

Multiple occurrences of key_n can occur in this example.  The goal is to calculate a rolling tally of the sum of the values for each key.


## Setup ##

1. Start Zookeeper
2. Start Kafka Server.  These examples assume it is available on port 9092
3. Create a Kafka Topic called `window-example`

```
./bin/kafka-topics.sh --create --topic window-example --bootstrap-server localhost:9092
```


## Run a Continuous Spark Streaming Query

Start a bash session the docker container `jupyterlab` and submit the example Spark streaming job [`/opt/workspace/notebooks/jobs/kafka-example.py`](https://github.com/edbullen/DockerSpark245/blob/master/notebooks/jobs/kafka-example.py)

```
docker exec -it jupyterlab bash
```
```
cd /opt/workspace/notebooks/jobs
./spark-submit.sh kafka-example.py
```

There will be a repeated summary of null processing results until some test data is provided.

```
+--------+---------------+
|test_key|sum(test_value)|
+--------+---------------+
+--------+---------------+
```

## Generate Streaming Data 

The Kafka producer client can be used to interactively generate a data stream.  At the same time the output of the Spark streaming query can be checked to see how the stream of data is processed.

#### Start a Producer
```
./bin/kafka-console-producer.sh --topic window-example --bootstrap-server localhost:9092 
```
 
#### Enter test data in the Kafka producer

Enter key-value strings separated by new-line (just hit enter).  These are parsed by kafka-example.py

EG
```
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
```
#### Check the output of the Spark jobs


`kafka-example.py` should process the events in micro-batches and periodically update the summary results based on the sum-by-key for all values as new key-value pairs are entered into the producer.

EG

```
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
```



