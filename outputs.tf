output "authentication_alb_dns" {
  value       = aws_lb.authentication_alb.dns_name
  description = "The DNS name for Internal AWS Application Load Balancer"
}

output "s3_arn" {
  value       = aws_s3_bucket.s3_bucket_excel.arn
  description = "ARN for S3 Bucket Secrets"
}

output "web_alb_subnet" {
  value = aws_lb.web_alb.subnet_mapping
}

output "authentication_alb_subnet" {
  value = aws_lb.authentication_alb.subnet_mapping
}
