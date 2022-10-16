# route53.tf | Route53 Domain Configuration

resource "aws_route53_zone" "domain" {
  name = var.app_domain
}

resource "aws_route53_record" "www" {
  zone_id         = aws_route53_zone.domain.zone_id
  name            = var.app_domain
  allow_overwrite = true
  type            = "A"

  alias {
    name                   = aws_lb.external_alb.dns_name
    zone_id                = aws_lb.external_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nameservers" {
  zone_id         = aws_route53_zone.domain.zone_id
  name            = var.app_domain
  allow_overwrite = true
  ttl             = 172800
  type            = "NS"
  records         = var.app_domain_ns
}

resource "aws_route53_record" "start_of_authority" {
  zone_id         = aws_route53_zone.domain.zone_id
  name            = var.app_domain
  allow_overwrite = true
  ttl             = 3600
  type            = "SOA"
  records         = [var.app_domain_soa]
}
