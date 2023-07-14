import logging

from pyspark.sql import SparkSession
from pyspark.sql.functions import avg
from pyspark.sql.functions import countDistinct


def main():
    # Initialize SparkSession with Delta Lake configurations
    spark = (
        SparkSession.builder.appName("TagRatingAnalysis")
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
    input_path3 = "s3://uffic-silver-eucentral1-473178649040-dev/movielens/tag_count/"
    input_path4 = "s3://uffic-silver-eucentral1-473178649040-dev/movielens/tags/"
    output_path = "s3://uffic-gold-eucentral1-473178649040-dev/movie_analysis/tag_ratings_over_years/"

    # Read Silver DataFrames
    logger.info("Reading data from {}".format(input_path1))
    metadata_df = spark.read.format("delta").load(input_path1)

    logger.info("Reading data from {}".format(input_path2))
    ratings_df = spark.read.format("delta").load(input_path2)

    logger.info("Reading data from {}".format(input_path3))
    tag_count_df = spark.read.format("delta").load(input_path3)

    logger.info("Reading data from {}".format(input_path4))
    tags_df = spark.read.format("delta").load(input_path4)

    # Join the dataframes and calculate the average rating for each tag
    tag_ratings = (
        tag_count_df.join(tags_df, on="tag_id", how="inner")
        .join(ratings_df, on="item_id", how="inner")
        .join(metadata_df, on="item_id", how="inner")
        .groupBy("tag", "year")
        .agg(avg("rating").alias("avg_rating"), countDistinct("item_id").alias("num_movies"))
    )

    # Filter the tags which have less than 5 movies
    tag_ratings_filtered = tag_ratings.filter(tag_ratings.num_movies >= 5)

    # Write DataFrame to S3 as Delta Lake
    logger.info("Writing data to {}".format(output_path))
    tag_ratings_filtered.write.format("delta").option("path", output_path).mode("overwrite").save()

    logger.info("Data written to {}".format(output_path))


if __name__ == "__main__":
    main()
