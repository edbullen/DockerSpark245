# Kafka Standalone Local Cluster #

The approach taken here is to run Kafka service locally in a JVM, not in a Docker Container.
  
Kafka dependancies:
+ Java
+ Zookeeper

#### Default Port Settings ####

Apache Kafka will run on port 9092 and Apache Zookeeper will run on port 2181.

## Part 1 - Java Install ##

Install JDK that is suitable for the versions of Zookeeper and Kafka that will used.

- Install the **JDK**, not JRE version of Java.

The example versions in this note are run with Java 1.8:

```
$ java -version
java version "1.8.0_301"
Java(TM) SE Runtime Environment (build 1.8.0_301-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.301-b09, mixed mode)
```

When installing Java on **Windows**, *do not install Java in the default `C:\Program Files` location*.  Choose an installation path with *no spaces*, otherwise some Kafka and Zookeeper scripts may fail.

## Part 2 - Zookeeper Install ##
Zookeeper acts as a coordinator service for managing processes in a distributed compute environment.  

Zookeper install instructions are here:  https://zookeeper.apache.org/doc/r3.4.5/zookeeperStarted.html

Download Zookeeper and follow the instructions for **Standalone Operation**.
(this note was written using version 3.7.0 of Zookeper)  

+ Create a dedicated folder for the Zookeeper software  
+ Create a dedicated folder for the Zookeeper process to persist logs and memory snapshots  
+ Unzip and Un-Tar the zipped archive downloaded from the Zookeeper Apache website  
+ Create a new `zoo.cfg` file (the name is arbitrary) in the `conf` directory that exists in the extracted Zookeeper installation package  

**cfg Example:**  
```
tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
admin.serverPort=9876
```
+ Change the `dataDir` entry to match the Zookeeper data persist location created earlier.  
For Windows installations, use a forward-slash separator between folders, EG `dataDir=C:/Software/zookeeper/data`. 

+ Change the `admin.serverPort` so that the Zookeeper admin server port (default is 8080) doesn't clash with the Spark Master on port 8080.   
The Zookeper admin server can be viewed in a web-browser at `localhost:9876/commands` (assuming the port has been changed to 9876).  
  


## Part 3 - Kafka Install and Configure ##

1. Download binary from http://kafka.apache.org/downloads.html  (this note was written using version **2.5.1**, released August 2020). *Take care to download the binary version, not the source-code version.*  
2. Extract to a dedicated folder - EG on Windows `C:\Software\kafka\2.5.1` or on Mac ` /usr/local/kafka`
3. Set up the configuration in the `./config` folder where the Kafka software is extracted.

#### Kafka server.properties changes ####

Each broker must have it's own properties config.  Copy the sample configuration in `./conf/server.properties` and make a copy for each broker, EG
- Broker 1: `server.b1.properties`  
- Broker 2: `server.b2.properties`  
  
Set the Broker ID in each server properties file for the brokers.  Each broker must have a unique ID, EG:
- Broker 1: `server.b1.properties`  set `broker.id=1`  
- Broker 2: `server.b2.properties`  set `broker.id=2`    
  
- Set the Log Location in each properties file.  If working in a Windows environment, it is possible to use Windows-style absolute paths (but *escape backslashes with another backslash*), EG:  
`log.dirs=C:\\Software\\kafka\\logs`.  On a Mac, set to something like `log.dirs=/tmp/kafka-logs` 
  
Leave the rest of the configuration options with their default values for a simple test configuration.   

#### Additional windows notes

To avoid issues connecting from within a Docker container back to the Kafka server (default location = `host.docker.internal:9092`),
it may be necessary to follow the workaround in this discussion: https://github.com/docker/for-win/issues/2402.

Edit the C:\Windows\System32\drivers\etc\hosts file and comment out
```
192.168.1.170 host.docker.internal
192.168.1.170 gateway.docker.internal
```
and change it to
```
127.0.0.1 host.docker.internal
127.0.0.1 gateway.docker.internal
```

## Part 4 - Start Zookeeper ##

**Start Zookeeper**
```commandline
bin/zkServer.sh start
```

**Start Zookeeper in Windows Command Shell**
```commandline
bin\zkServer.cmd
```
(CTRL-C to exit)  
  
**Check Zookeeper Status**
```commandline
bin/zkServer.sh status
```
Example output:
```commandline
/c/Program Files (x86)/Common Files/Oracle/Java/javapath/java
ZooKeeper JMX enabled by default
Using config: C:\Software\zookeeper\3.7.0\conf\zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: standalone
```

## Part 5 -  Start Kafka ##

### Starting on Mac ###
- In a command-window, change to the location where Kafka was installed, EG:
```
cd /usr/local/kafka
```
- Use the `kafka-server-start.sh` script to start a Kafka server, specifying the correct broker properties file, EG: 
```
./bin/kafka-server-start.sh ./config/server.b1.properties
```

### Starting on Windows ###

- Open a Windows CMD window and change directory to the `bin\windows` subdirectory, EG:  
 `cd C:\software\kafka\2.5.1\bin\windows`
 
- Use the `kafka-server-start.bat` script to start a Kafka server, specifying the correct broker properties file, EG:  
`kafka-server-start.bat ..\..\config\server.b1.properties` 

- At this point, the connection should be detected by Zookeeper and a note pasted in the Zookeeper console output:  
`2020-12-02 12:38:41,943 [myid:] - INFO  [SyncThread:0:FileTxnLog@216] - Creating new log file: log.1`  

### Quick-Start Test on Mac ###
Ref: https://kafka.apache.org/25/documentation.html#quickstart

- Open another command window (separate from the Kafka server window)  
   
- **create a topic** named "quickstart-events" with a single partition and only one replica:
```
./bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
```

- Run the **console producer client** to write a few events into the `quickstart-events` topic.  
By default, each line entered will result in a separate event being written to the topic.  

```
./bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
```
enter text into the STDIN reader to add new events:
```
This is my first event
This is my second event
```

(CTRL-C to stop entering new events)
- Run the **console consumer client** to consume the events (open another command window to do this):
```
./bin/kafka-console-consumer.sh  --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```
### Quick-Start Test on Windows ###

Ref: https://kafka.apache.org/25/documentation.html#quickstart

-  Open another command window (separate from the Kafka server window)  
   
- **create a topic** named "quickstart-events" with a single partition and only one replica:
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

- Run the **console producer client** to write a few events into the `quickstart-events` topic (this can run in the CMD window that was used to create a new topic).  
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

- Run the **console consumer client** to consume the events (open another command window to do this):

```
bin\windows\kafka-console-consumer.bat --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```

### Consume Events *from-beginning* Vs New Events ###

The `--from-beginning` flag reads *all* records from the earliest available record.

Just omit this flag to only consume new events as they are produced
```
bin\windows\kafka-console-consumer.bat --topic quickstart-events --bootstrap-server localhost:9092
```
### Change the Message Rention Period ###

MacOS - set to 1 hour:
```
bin/kafka-configs --zookeeper localhost:2181 \
  --entity-type topics \
  --alter --add-config retention.ms=3600000 \
  --entity-name quickstart-events
```  
Windows - set to 1 hour:
```
bin\windows\kafka-configs.bat --zookeeper localhost:2181 --entity-type topics --alter --add-config retention.ms=3600000 --entity-name quickstart-events  
```