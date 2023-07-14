import logging

from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark.sql.functions import count
from pyspark.sql.functions import expr
from pyspark.sql.functions import when


def main():
    # Initialize SparkSession with Delta Lake configurations
    spark = (
        SparkSession.builder.appName("MoviesAnalytics")
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
    input_path3 = "s3://uffic-silver-eucentral1-473178649040-dev/imdb/reviews/"
    output_path = "s3://uffic-gold-eucentral1-473178649040-dev/movie_analysis/movie_analytics/"

    # Read Silver DataFrames
    logger.info("Reading data from {}".format(input_path1))
    metadata_df = spark.read.format("delta").load(input_path1)

    logger.info("Reading data from {}".format(input_path2))
    ratings_df = spark.read.format("delta").load(input_path2)

    logger.info("Reading data from {}".format(input_path3))
    reviews_df = spark.read.format("delta").load(input_path3)

    # Count positive and negative ratings
    ratings_pos_neg = (
        ratings_df.withColumn("rating_pos", when(col("rating") > 3, 1).otherwise(0))
        .withColumn("rating_neg", when(col("rating") <= 3, 1).otherwise(0))
        .groupBy("item_id")
        .agg(
            (count(when(col("rating_pos") == 1, 1)) - count(when(col("rating_neg") == 1, 1))).alias("discrepancy"),
            count("rating").alias("total_ratings"),
            expr("avg(rating)").alias("avg_rating"),
        )
    )

    # Filter movies with at least 5 ratings
    ratings_filtered = ratings_pos_neg.filter(col("total_ratings") >= 5)

    # Calculate average discrepancy
    ratings_discrepancy = ratings_filtered.withColumn("avg_discrepancy", col("discrepancy") / col("total_ratings"))

    # Count reviews per movie
    reviews_count = reviews_df.groupBy("item_id").agg(count("txt").alias("num_reviews"))

    # Join metadata and average discrepancy DataFrames
    movie_analytics = (
        ratings_discrepancy.join(metadata_df, on=["item_id"], how="inner")
        .join(reviews_count, on=["item_id"], how="left")
        .select("item_id", "title", "avg_discrepancy", "avg_rating", "num_reviews")
    )

    # Fill null values in num_reviews column with 0
    movie_analytics = movie_analytics.fillna({"num_reviews": 0})

    # Write DataFrame to S3 as Delta Lake
    logger.info("Writing data to {}".format(output_path))
    movie_analytics.write.format("delta").option("path", output_path).mode("overwrite").save()

    logger.info("Data written to {}".format(output_path))


if __name__ == "__main__":
    main()
