# Spark and Kafka in Docker Cluster #

This build is based on the following article:  https://towardsdatascience.com/apache-spark-cluster-on-docker-ft-a-juyterlab-interface-418383c95445 
 written by [@dekoperez](https://twitter.com/dekoperez) and then adjusted and extended to include Spark Streaming and PySpark compatibility.  
  
A two-node cluster and a spark master are built as Docker images along with a separate JupyterLab environment.  Each runs in a separate container and shares a network and shared file-system.  
  
![Cluster](./images/cluster.png)     
  
## Spark and Hadoop Configuration and Release Information ##

Build as of 2021-01-01  
   
Spark Version `2.4.5` is used to ensure compatibility with PySpark and Kafka and enable spark-streaming that is compatible with PySpark. The Hadoop version is `2.7`
  
These are set at the start of the `build.sh` script and passed in as environment variables to each of the Docker build stages.  
  
Apache Spark is running in *Standalone Mode* and controls its own master and worker nodes instead of Yarn managing them.     
    
Apache Spark with Apache Hadoop support is used to allow the cluster to simulate HDFS distributed filesystem using the shared volume `shared-workspace` that is created during the docker-compose initialisation - as per this  `docker-compose.yml` excerpt:
```
volumes:
  shared-workspace:
    name: "hadoop-distributed-file-system"
    driver: local
```

### Build ###

The Docker images are built by the `build.sh` script.

The following Docker images are created:  
+ `cluster-base` - this provides the shared directory (`/opt/workspace`) for the HDFS simulation.  
+ `spark-base`  - base Apache Spark image to build the Spark Master and Spark Workers on.   
+ `spark-master` - Spark Master that allows Worker nodes to connect via SPARK_MASTER_PORT, also exposes the Spark Master UI web-page (port 8080).  
+ `spark-worker` - multiple Spark Worker containers can be started from this image to form the cluster.    
+ `jupyterlab` -  built on top of the cluster-base with Python and JupyterLab environment set up and sharing the same shared workspace file-system mount as the rest of the cluster.  
  
To allow the JupyterLab container to access the external ./notebooks file-share, enable access to this location in the Docker desktop configuration tool:  

![Docker Desktop Windows settings](./images/WindowsDockerFileshare.png)    

### Cluster Dependancies ###

*Docker Compose* is used to link all the cluster components together so that an overall running cluster service can be started.  
  
`docker-compose.yml` initialises a shared cluster volume for the shared filesystem (HDFS simulation) and also maps ./notebooks to a mount point in the JupyterLab Docker container.  

Various other port-mappings and configuration details are set in this configuration file.  Because all the worker nodes need to be referenced at `localhost`, they are mapped to different port numbers (ports 8081 and 8082 for worker 1 and 2).

##### Compute and Memory Resources #####

Re-size the `SPARK_WORKER_CORES` and `SPARK_WORKER_MEMORY` to size the cluster so that it can run in the local environment.  

*check the amount of host resources allocated to Docker in the Docker Desktop configuration*   
        
    
### Start ###

```
docker-compose up --detach
```


### Stop ###
```
docker-compose down
```

### Spark-Master Logs and Interactive Shell ###
##### Connect to Spark Master with Interactive Shell #####
List the running Docker containers and identify the `CONTAINER ID` hash for the `spark-master`
```
docker ps
```
Start a shell inside the docker container and use Linux commands such as `ps`, `netstat`, `vi` / `vim` etc
```
docker exec -it <container_hash_id> bash
```
(If running in git-bash on Windows, precede the docker command with `winpty` to enable an interactive terminal)  

Connect to the worker nodes in a similar fashion.
##### View Docker Container Logs #####  
Logs can be viewed from the Docker host environment (without connecting into a container):
```
docker logs <container_hash_id> 
```  
View the Docker Compose Logs as follows:
```buildoutcfg
docker-compose logs
```
For **Spark Jobs that Hang For Ever** waiting to start, check the `docker-compose` logs for ` check your cluster UI to ensure that workers are registered and have sufficient resources`  This means that not enough resources (memory or CPU) were available to run the job.  Kill the job and configure with enough resources.

### Monitoring the Spark Cluster and Killing Application Jobs ###

View the overall state of the cluster via the *Spark Master Web UI* at `http://localhost:8080/`   
  
This also lists the URL for the *Spark Master Service*: `spark://spark-master:7077`   

Because the cluster is running in Standalone Mode (*Not* Yarn), it is not possible to use the usual `yarn application -kill` command.  Instead, use the Spark Master web UI to list running jobs and kill them by selecting the "kill" link in the Running Applications view.
![Cluster](./images/master-jobs.png)      

### Spark History Server ###

Access the history server to view complete (and incomplete) applications on a per node basis.  
To view the node 1 history view `http://localhost:18081` in a web browser  
to vuew the node 2 history view `http://localhost:18082`  

## Kafka Build and Operations ##






# Connect to Cluster via JupyterLab to run Interactive Notebook Sessions #

Use a web-browser to connect to `http://localhost:8888`  
  
This is enabled by the Docker VM instance which exposes port 8888 to local-host, with a configuration based on top of the Docker image "cluster-base"  

The Jupyter notebooks are stored in the shared workspace `/opt/workspace245/notebooks` which is mounted on a Docker Volume and mapped to a local directory on the docker host.  The volume configuration and mapping to a local file-system mount is specified in the `docker-compose.yml` file and executed at run-time:
```
...
services:
  jupyterlab:
    image: jupyterlab
    container_name: jupyterlab
    ports:
      - 8888:8888
    volumes:
      - shared-workspace:/opt/workspace
      - ./notebooks:/opt/workspace/notebooks
...      
```


#### Start a PySpark Session ####
```
from pyspark.sql import SparkSession

spark = SparkSession.\
        builder.\
        appName("pyspark-notebook-1").\
        master("spark://spark-master:7077").\
        config("spark.executor.memory", "512m").\
        getOrCreate()
```

#### End a PySpark Session ####
**Important**: To make sure the memory resources of a Jupyter Notebook session are freed up, always stop the Spark session when finished in the notebook, as follows:
```
spark.stop()
```