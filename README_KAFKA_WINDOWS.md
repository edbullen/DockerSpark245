# Kafka Standalone Local Cluster #

Run Kafka service locally in a JVM, not in a Docker Container.

Pre-req is Zookeeper service running on port.

1. Download binary from http://kafka.apache.org/downloads.html  (tried  version 2.5.1 .tgz file for this note). *Take care not to download the source-code version.*  
2. Extract to dedicated folder - EG C:\Software\Kafka\2.5.1  
3. Set up the configuration in the `./config` folder

#### Kafka server.properties changes ####

Each broker must have it's own properties config.  Copy the sample configuration in `./conf/server.properties` and make a copy for each broker, EG
- Broker 1: `server.b1.properties`  
- Broker 2: `server.b2.properties`  
  
Set the Broker ID in each server properties file for the brokers.  Each broker must have a unique ID, EG:
- Broker 1: `server.b1.properties`  set `broker.id=1`  
- Broker 2: `server.b2.properties`  set `broker.id=2`    
  
- Set the Log Location in each properties file.  It is possible to use Windows-style absolute paths, EG:  
`log.dirs=C:\\logs`
  
Leave the rest of the configuration options at there default values for a simple test configuration.   

#### Default Port Settings ####

Apache Kafka will run on port 9092 and Apache Zookeeper will run on port 2181.

## Start Kafka on Windows ##

- Open a Windows CMD window and change directory to the `bin\windows` subdirectory, EG:  
 `cd C:\software\kafka\2.5.1\bin\windows`
 
- Use the `kafka-server-start.bat` to start a Kafka server, specifying the correct broker properties file, EG:  
`kafka-server-start.bat ..\..\config\server.b1.properties` 

- At this point, the connection should be detected by Zookeeper and a note pasted in the Zookeeper console output:  
`2020-12-02 12:38:41,943 [myid:] - INFO  [SyncThread:0:FileTxnLog@216] - Creating new log file: log.1`  

## Quick-Start Hello World Test ##

Ref: https://kafka.apache.org/25/documentation.html#quickstart

-  In another Windows CMD window:  
   
- create a topic named "quickstart-events" with a single partition and only one replica:
```
bin\windows\kafka-topics.bat --create --topic quickstart-events --bootstrap-server localhost:9092
```

In the Windows CMD window where Kafka was started, output similar to the following is displayed:

```
[2021-03-26 15:22:16,195] INFO Created log for partition quickstart-events-0 in C:\logs\quickstart-events-0 with properties {compression.type -> producer, message.downconversion.enable -> true, min.insync.replicas -> 1, segment.jitter.ms -> 0, cleanup.policy -> [delete], flush.ms -> 9223372036854775807, segment.bytes -> 1073741824, retention.ms -> 604800000, flush.messages -> 9223372036854775807, message.format.version -> 2.5-IV0, file.delete.delay.ms -> 60000, max.compaction.lag.ms -> 9223372036854775807, max.message.bytes -> 1048588, min.compaction.lag.ms -> 0, message.timestamp.type -> CreateTime, preallocate -> false, min.cleanable.dirty.ratio -> 0.5, index.interval.bytes -> 4096, unclean.leader.election.enable -> false, retention.bytes -> -1, delete.retention.ms -> 86400000, segment.ms -> 604800000, message.timestamp.difference.max.ms -> 9223372036854775807, segment.index.bytes -> 10485760}. (kafka.log.LogManager)
[2021-03-26 15:22:16,196] INFO [Partition quickstart-events-0 broker=1] No checkpointed highwatermark is found for partition quickstart-events-0 (kafka.cluster.Partition)
[2021-03-26 15:22:16,198] INFO [Partition quickstart-events-0 broker=1] Log loaded for partition quickstart-events-0 with initial high watermark 0 (kafka.cluster.Partition)
[2021-03-26 15:22:16,203] INFO [Partition quickstart-events-0 broker=1] quickstart-events-0 starts at leader epoch 0 from offset 0 with high watermark 0. Previous leader epoch was -1. (kafka.cluster.Partition)
```

Run the console producer client to write a few events into the `quickstart-events` topic.  
By default, each line entered will result in a separate event being written to the topic.  

```
bin\windows\kafka-console-producer.bat --topic quickstart-events --bootstrap-server localhost:9092
```
enter text into the STDIN reader to add new events:
```
This is my first event
This is my second event
```

(CTRL-C to stop entering new events)


Consume the events:

```
bin\windows\kafka-console-consumer.bat --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```