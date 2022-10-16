output "internal_alb_dns" {
  value       = aws_lb.internal_alb.dns_name
  description = "The DNS name for Internal AWS Application Load Balancer"
}
