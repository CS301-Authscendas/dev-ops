# s3.tf | S3 Bucket Configuration

resource "aws_s3_bucket" "s3_bucket_excel" {
  bucket = "${var.app_name}-excel"

  tags = {
    Name        = "${var.app_name}-excel"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning_excel" {
  bucket = aws_s3_bucket.s3_bucket_excel.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "s3_bucket_secrets" {
  bucket = "${var.app_name}-secrets"

  tags = {
    Name        = "${var.app_name}-secrets"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning_secrets" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id

  versioning_configuration {
    status = "Enabled"
  }
}
