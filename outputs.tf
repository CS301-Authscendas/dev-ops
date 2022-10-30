output "gateway_alb_dns" {
  value       = aws_lb.gateway_alb.dns_name
  description = "The DNS name for External Gateway AWS ALB"
}

output "web_alb_dns" {
  value       = aws_lb.web_alb.dns_name
  description = "The DNS name for External Web AWS ALB"
}

output "organizations_alb_dns" {
  value       = aws_lb.organizations_alb.dns_name
  description = "The DNS name for Internal Organizations AWS ALB"
}

output "s3_arn" {
  value       = aws_s3_bucket.s3_bucket_excel.arn
  description = "ARN for S3 Bucket Secrets"
}

output "jwt_key_arn" {
  value       = aws_kms_key.jwt_signing_key.arn
  description = "ARN for KMS JWT Key"
}
