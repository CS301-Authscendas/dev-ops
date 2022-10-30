resource "aws_s3_object" "webserver_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "webserver/.env"
  source = "env/webserver/.env"
}

resource "aws_s3_object" "authentication_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "authentication/.env"
  source = "env/authentication/.env"
}

resource "aws_s3_object" "notifications_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "notifications/.env"
  source = "env/notifications/.env"
}

resource "aws_s3_object" "organizations_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "organizations/.env"
  source = "env/organizations/.env"
}

resource "aws_s3_object" "gateway_env" {
  bucket = aws_s3_bucket.s3_bucket_secrets.id
  key    = "gateway/.env"
  source = "env/gateway/.env"
}

