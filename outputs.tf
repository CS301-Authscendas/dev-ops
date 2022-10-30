output "authentication_alb_dns" {
  value       = aws_lb.gateway_alb.dns_name
  description = "The DNS name for Gateway AWS Application Load Balancer"
}

output "s3_arn" {
  value       = aws_s3_bucket.s3_bucket_excel.arn
  description = "ARN for S3 Bucket Secrets"
}
