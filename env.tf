resource "aws_s3_object" "webserver_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "webserver/.env"
  source = "webserver/.env"
}

resource "aws_s3_object" "authentication_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "authentication/.env"
  source = "authentication/.env"
}

resource "aws_s3_object" "notifications_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "notifications/.env"
  source = "notifications/.env"
}

resource "aws_s3_object" "users_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "users/.env"
  source = "users/.env"
}

