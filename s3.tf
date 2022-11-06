# s3.tf | S3 Bucket Configuration

resource "aws_s3_bucket" "s3_bucket_excel" {
  bucket        = "${var.app_name}-excel"
  force_destroy = true

  tags = {
    Name        = "${var.app_name}-excel"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_excel_acl" {
  bucket = aws_s3_bucket.s3_bucket_excel.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "s3_bucket_excel_cors" {
  bucket = aws_s3_bucket.s3_bucket_excel.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST"]
    allowed_origins = [var.web_domain, "http://localhost:8000"]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_excel_configuration" {
  bucket = aws_s3_bucket.s3_bucket_excel.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning_excel" {
  bucket = aws_s3_bucket.s3_bucket_excel.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "s3_key" {
  description = "Used to encrypt bucket objects"
}

resource "aws_s3_bucket" "s3_bucket_secrets" {
  bucket        = "${var.app_name}-secrets"
  force_destroy = true

  tags = {
    Name        = "${var.app_name}-secrets"
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_secrets_acl" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3_bucket_secrets_versioning_excel" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id

  versioning_configuration {
    status = "Enabled"
  }
}
