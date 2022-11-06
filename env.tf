resource "aws_s3_object" "env" {
  for_each = var.microservices
  bucket   = aws_s3_bucket.s3_bucket_secrets.id
  key      = "${each.key}/.env"
  source   = "env/${each.key}/.env"
}
