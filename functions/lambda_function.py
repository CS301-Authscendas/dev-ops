import base64
import cgi
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
        content_type_header = event["headers"]["content-type"]
        body = base64.b64decode(event["body"])

        fp = io.BytesIO(body)
        pdict = cgi.parse_header(content_type_header)[1]

        if "boundary" in pdict:
            pdict["boundary"] = pdict["boundary"].encode("utf-8")
        pdict["CONTENT-LENGTH"] = len(body)
        form_data = cgi.parse_multipart(fp, pdict)
        print("form_data=", form_data)

        file = io.BytesIO(form_data["file"][0])
        file_name = form_data["file_name"][0]

        bucket = s3.Bucket(bucket_name)
        bucket_object = bucket.Object(file_name + ".xlsx")
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
