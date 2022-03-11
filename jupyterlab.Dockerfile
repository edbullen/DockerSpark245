FROM cluster-base

# -- Layer: JupyterLab

ARG spark_version=2.4.5
ARG jupyterlab_version=2.1.5

RUN apt-get update -y && \
    apt-get install -y python3-pip && \
	pip3 install pypandoc && \
    pip3 install pyspark==${spark_version} jupyterlab==${jupyterlab_version} && \
	pip3 install wget && \
    pip3 install numpy && pip3 install pandas && pip3 install matplotlib && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/local/bin/python3 /usr/bin/python

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

