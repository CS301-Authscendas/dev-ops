# output.tf | Relevant URLs of the Application

output "gateway_alb_dns" {
  value       = aws_lb.gateway_alb.dns_name
  description = "The DNS name for External Gateway AWS ALB"
}

output "web_alb_dns" {
  value       = aws_lb.web_alb.dns_name
  description = "The DNS name for External Web AWS ALB"
}
