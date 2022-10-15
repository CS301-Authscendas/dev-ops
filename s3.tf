# s3.tf | S3 Bucket Configuration

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.app_name}-partner-users"

  tags = {
    Name        = "${var.app_name}-partner-users"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
