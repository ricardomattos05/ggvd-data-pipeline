import logging

from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.sql.functions import floor


def main():
    # Initialize SparkSession with Delta Lake configurations
    spark = (
        SparkSession.builder.appName("movielens_tags_processing")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )

    # Initialize logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    logger.info("Starting the Glue job...")

    # Obtain S3 paths from environment variables
    input_path = "s3://uffic-bronze-eucentral1-473178649040-dev/movielens/tags.json"
    output_path = "s3://uffic-silver-eucentral1-473178649040-dev/movielens/tags/"

    # Read raw data
    logger.info("Reading data from {}".format(input_path))
    tags_df = spark.read.json(input_path)

    # Remove duplicates
    tags_df = tags_df.dropDuplicates()

    # Write DataFrame to S3 as Delta Lake
    logger.info("Writing data to {}".format(output_path))

    tags_df.write.format("delta").option("path", output_path).mode("append").save()

    logger.info("Data written to {}".format(output_path))


if __name__ == "__main__":
    main()
