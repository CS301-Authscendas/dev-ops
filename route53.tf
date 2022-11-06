# route53.tf | Route53 Domain Configuration

resource "aws_route53_zone" "web_domain" {
  name = var.web_domain
}

resource "aws_route53_record" "web_domain" {
  zone_id         = aws_route53_zone.web_domain.zone_id
  name            = aws_route53_zone.web_domain.name
  allow_overwrite = true
  type            = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "subdomain" {
  zone_id = aws_route53_zone.web_domain.zone_id
  name    = aws_route53_zone.subdomain.name
  type    = "NS"
  ttl     = 86400
  records = aws_route53_zone.subdomain.name_servers
}

resource "aws_route53_zone" "subdomain" {
  name = "api.${var.web_domain}"
}

resource "aws_route53_record" "subdomain_to_gateway" {
  zone_id         = aws_route53_zone.subdomain.zone_id
  name            = aws_route53_zone.subdomain.name
  allow_overwrite = true
  type            = "A"

  alias {
    name                   = aws_lb.gateway_alb.dns_name
    zone_id                = aws_lb.gateway_alb.zone_id
    evaluate_target_health = true
  }
}
