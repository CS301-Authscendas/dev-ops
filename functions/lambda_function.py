import io
import os

import boto3


def lambda_handler(event, context):
    s3 = boto3.client("s3")
    db = boto3.client("dynamodb")

    try:
        bucket_name = os.getenv("BUCKET_NAME")
        file_name = event["file_name"]

        file = io.BytesIO(bytes(event["file_content"], encoding="utf-8"))
        print(file)

        bucket = s3.Bucket(bucket_name)
        bucket_object = bucket.Object(file_name)
        bucket_object.upload_fileobj(file)

        print("Upload Successful")
        return {
            "statusCode": 200,
            "body": f"Upload succeeded: {file_name} has been uploaded to Amazon S3 in bucket {bucket_name}",
        }
    except FileNotFoundError:
        print("The file was not found")
        return None
