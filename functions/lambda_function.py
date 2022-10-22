import io
import os

import boto3


def lambda_upload(event, context):
    if event["requestContext"]["http"]["method"] == "OPTIONS":
        return {"statusCode": 200, "body": "ok"}

    s3 = boto3.resource("s3")

    try:
        bucket_name = os.getenv("BUCKET_NAME")
        file_name = "test"

        file = io.BytesIO(bytes(event["body"], encoding="utf-8"))
        print(file)
        print(file.getbuffer(), file.getvalue())

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
