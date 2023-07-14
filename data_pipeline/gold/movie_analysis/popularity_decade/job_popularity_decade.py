import logging

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.functions import countDistinct
from pyspark.sql.functions import floor


def main():
    # Initialize SparkSession with Delta Lake configurations
    spark = (
        SparkSession.builder.appName("PopularPeopleByDecade")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )

    # Initialize logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    logger.info("Starting the Glue job...")

    # Obtain S3 paths from environment variables
    input_path1 = "s3://uffic-silver-eucentral1-473178649040-dev/imdb/metadata/"
    input_path2 = "s3://uffic-silver-eucentral1-473178649040-dev/movielens/ratings/"
    output_path = "s3://uffic-gold-eucentral1-473178649040-dev/movie_analysis/popular_people_by_decade/"

    # Read Silver DataFrames
    logger.info("Reading data from {}".format(input_path1))
    metadata_df = spark.read.format("delta").load(input_path1)

    logger.info("Reading data from {}".format(input_path2))
    ratings_df = spark.read.format("delta").load(input_path2)

    # Extract the decade from the year
    metadata_df = metadata_df.withColumn("decade", (floor(metadata_df["year"] / 10) * 10))

    # Explode the starring and directedby arrays into new rows
    starring_df = metadata_df.select(
        metadata_df["item_id"], metadata_df["decade"], F.explode(metadata_df["starring"]).alias("name")
    )
    starring_df = starring_df.withColumn("role", F.lit("Actor"))

    directedby_df = metadata_df.select(
        metadata_df["item_id"], metadata_df["decade"], F.explode(metadata_df["directedBy"]).alias("name")
    )
    directedby_df = directedby_df.withColumn("role", F.lit("Director"))

    # Union the two dataframes together
    people_df = starring_df.union(directedby_df)

    # Group by role, name, and decade. Count the number of unique movies and calculate the average rating
    people_agg = (
        people_df.join(ratings_df, on="item_id", how="inner")
        .groupBy("role", "name", "decade")
        .agg(countDistinct("item_id").alias("num_movies"), F.avg("rating").alias("avg_rating"))
    )

    # Write the DataFrame to S3 as Delta Lake
    logger.info("Writing data to {}".format(output_path))
    people_agg.write.format("delta").option("path", output_path).mode("overwrite").save()

    logger.info("Data written to {}".format(output_path))


if __name__ == "__main__":
    main()
