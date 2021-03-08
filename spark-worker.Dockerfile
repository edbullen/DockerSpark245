FROM spark-base

# -- Runtime

ARG spark_worker_web_ui=8081

EXPOSE ${spark_worker_web_ui}
EXPOSE 18080

COPY ./spark-defaults.conf conf/spark-defaults.conf

CMD bash -c "sbin/start-history-server.sh  &&  bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> logs/spark-worker.out" 