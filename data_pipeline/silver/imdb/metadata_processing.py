import logging

from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.sql.functions import regexp_extract
from pyspark.sql.functions import split
from pyspark.sql.functions import when


def main():
    # Initialize SparkSession with Delta Lake configurations
    spark = (
        SparkSession.builder.appName("imdb_metadata_processing")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )

    # Initialize logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    logger.info("Starting the Glue job...")

    # Obtain S3 paths from environment variables
    input_path = "s3://uffic-bronze-eucentral1-473178649040-dev/imdb/metadata.json"
    output_path = "s3://uffic-silver-eucentral1-473178649040-dev/imdb/metadata/"

    # Read raw data
    logger.info("Reading data from {}".format(input_path))
    metadata_df = spark.read.json(input_path)

    # Remove duplicates
    metadata_df = metadata_df.dropDuplicates()

    # Extract year from movie title
    metadata_df = metadata_df.withColumn("year", regexp_extract(col("title"), "\((\d{4})\)", 1))

    # Substituir valores em branco no ano por 1900
    metadata_df = metadata_df.withColumn("year", when(metadata_df.year == "", "1600").otherwise(metadata_df.year))

    # Clean and transform directors and actors fields
    metadata_df = metadata_df.withColumn("directedBy", split(col("directedBy"), ", "))
    metadata_df = metadata_df.withColumn("starring", split(col("starring"), ", "))

    # Write DataFrame to S3 as Delta Lake
    logger.info("Writing data to {}".format(output_path))
    metadata_df.write.format("delta").option("path", output_path).mode("append").partitionBy("year").save()

    logger.info("Data written to {}".format(output_path))


if __name__ == "__main__":
    main()
