import json
import os

import boto3


sqs = boto3.client("sqs")
queue_url = os.environ.get("SQS_QUEUE_URL")


def lambda_handler(event, context):
    for i in range(0, 500, 100):
        message = {"start_page": i + 1, "end_page": i + 100}
        sqs.send_message(QueueUrl=queue_url, MessageBody=json.dumps(message))

    return {"statusCode": 200, "body": "Started data extraction"}
