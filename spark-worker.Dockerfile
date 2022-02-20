FROM spark-base

# -- Runtime
ARG spark_version=2.4.5

ARG spark_worker_web_ui=8081

EXPOSE ${spark_worker_web_ui}
EXPOSE 18080

RUN apt-get update -y && \
	apt install -y curl gcc &&\
	apt install -y build-essential zlib1g-dev libncurses5-dev && \
	apt install -y libsqlite3-dev && \
	apt install -y libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget && \
	curl -O https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tar.xz  && \
    tar -xf Python-3.7.9.tar.xz && cd Python-3.7.9 && ./configure --enable-optimizations && make -j 8 && \
    make install && \
    ln -s /usr/bin/python3 /usr/bin/python &&  \
    rm -rf /var/lib/apt/lists/* \
    && pip3 install pyspark==${spark_version}

COPY ./spark-defaults.conf conf/spark-defaults.conf

CMD bash -c "sbin/start-history-server.sh  &&  bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> logs/spark-worker.out" 