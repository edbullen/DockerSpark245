import sys
from pyspark.sql import SparkSession
from pyspark.sql.types import *

KAFKA_TOPIC = "window-example"

def parse_data_from_kafka_message(df, schema):
    """ take a Spark Streaming df and parse value col based on <schema>, return streaming df cols in schema """
    from pyspark.sql.functions import split
    assert df.isStreaming == True, "DataFrame doesn't receive streaming data"


    #split attributes to nested array in one Column
    col = split(df['value'], ',') 

    # expand col to multiple top-level columns
    for idx, field in enumerate(schema): 
        df = df.withColumn(field.name, col.getItem(idx).cast(field.dataType))
    return df.select([field.name for field in schema])


if __name__ == "__main__":
 
    spark = SparkSession.builder.appName(sys.argv[0])\
            .config("spark.eventLog.enabled", "true")\
            .config("spark.eventLog.dir", "file:///opt/workspace/events")\
            .getOrCreate()

    # Set log-level to WARN to avoid very verbose output
    spark.sparkContext.setLogLevel('WARN')

    # schema for parsing value string passed from Kafka
    testSchema = StructType([ \
            StructField("test_key", StringType()), \
            StructField("test_value", FloatType())])

    # Spark Streaming DataFrame, connect to Kafka topic served at host in bootrap.servers option
    df_kafka = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", "host.docker.internal:9092") \
        .option("subscribe", KAFKA_TOPIC) \
        .option("startingOffsets", "latest") \
        .load() \
        .selectExpr("CAST(value AS STRING)")

    # parse streaming data and apply a schema
    df_kafka = parse_data_from_kafka_message(df_kafka, testSchema)

    # query the spark streaming data-frame that has columns applied to it as defined in the schema
    query = df_kafka.groupBy("test_key").sum("test_value")

    # write the output out to the console for debugging / testing
    query.writeStream \
       .outputMode("complete") \
       .format("console") \
       .option("truncate", False) \
       .start() \
       .awaitTermination()
