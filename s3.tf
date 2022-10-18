# s3.tf | S3 Bucket Configuration

resource "aws_s3_bucket" "s3_bucket_excel" {
  bucket        = "${var.app_name}-excel"
  acl           = "public-read-write"
  force_destroy = true
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST"]
    allowed_origins = [var.app_domain]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

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

resource "aws_kms_key" "s3_key" {
  description = "Used to encrypt bucket objects"
}
