import base64
import email.parser
import io
import os

import boto3


def lambda_upload(event, context):
    print(event)
    if event["requestContext"]["http"]["method"] == "OPTIONS":
        return {"statusCode": 200, "body": "ok"}

    s3 = boto3.resource("s3")

    try:
        bucket_name = os.getenv("BUCKET_NAME")
        file_name = "test.xlsx"

        test = email.parser.BytesParser().parsebytes(base64.b64decode(event["body"]))
        print(
            test.get_param("name", header="content-disposition"),
            test.get_param("filename", header="content-disposition"),
            test.get_payload(decode=True),
        )

        file = io.BytesIO(bytes(event["body"], encoding="utf-8"))

        bucket = s3.Bucket(bucket_name)
        bucket_object = bucket.Object(file_name)
        bucket_object.upload_fileobj(file)

        print("Upload Successful")
        return {
            "statusCode": 200,
            "body": f"Upload succeeded: {file_name} has been uploaded to Amazon S3",
        }
    except FileNotFoundError:
        print("The file was not found")
        return {
            "statusCode": 404,
            "body": "The file was not found",
        }
