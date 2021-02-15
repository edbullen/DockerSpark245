FROM spark-base

RUN apt-get update && apt-get install -y vim
RUN apt-get update && apt-get install -y net-tools
RUN apt-get install -y iputils-ping


# -- Runtime
ARG spark_master_web_ui=8080

EXPOSE ${spark_master_web_ui} ${SPARK_MASTER_PORT}
CMD bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out 

