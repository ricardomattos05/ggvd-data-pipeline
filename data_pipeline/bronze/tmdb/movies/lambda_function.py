import json
import logging
import os

import boto3

from utils import get_movies
from utils import upload_to_s3


# Set up logging
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

S3_BUCKET_NAME = os.environ.get("BRONZE_BUCKET")
API_KEY = os.environ.get("API_KEY")
s3 = boto3.client("s3")


def lambda_handler(event, context):
    """
    The main Lambda handler function.

    Parameters:
    event (dict): AWS Lambda uses this parameter to pass in event data to the handler.
    context (aws.LambdaContext): AWS Lambda uses this parameter to provide runtime information to your handler.

    Returns:
    dict: A response dictionary.
    """

    logger.info("Lambda handler initiated")

    for record in event["Records"]:
        message = json.loads(record["body"])
        start_page = message["start_page"]
        end_page = message["end_page"]
        # Log the start and end pages
        logger.info(f"Start page: {start_page}, End page: {end_page}")

    # Loop through all pages and get movies.
    filmes = []
    for page_number in range(start_page, end_page + 1):
        filmes.extend(get_movies(page_number, API_KEY))
        logger.info(f"Retrieved movies for page: {page_number}")

    # Upload the movie data to S3.
    upload_success = upload_to_s3(filmes, s3, S3_BUCKET_NAME, start_page, end_page)
    logger.info("Movie data upload attempted")

    # Return an appropriate response based on the result of the upload.
    if upload_success:
        logger.info("Upload successful")
        return {"statusCode": 200, "body": "Upload concluído com sucesso!"}
    else:
        logger.error("Upload failed")
        return {"statusCode": 500, "body": "Falha no upload"}
