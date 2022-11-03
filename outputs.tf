# output.tf | Relevant URLs of the Application

output "gateway_alb_dns" {
  value       = aws_lb.gateway_alb.dns_name
  description = "The DNS name for External Gateway AWS ALB"
}

output "web_alb_dns" {
  value       = aws_lb.web_alb.dns_name
  description = "The DNS name for External Web AWS ALB"
}

output "ssl_certificate_pem" {
  value = lookup(acme_certificate.certificate, "certificate_pem")
}

output "ssl_issuer_pem" {
  value = lookup(acme_certificate.certificate, "issuer_pem")
}

output "ssl_private_key_pem" {
  value = nonsensitive(lookup(acme_certificate.certificate, "private_key_pem"))
}
