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
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}
