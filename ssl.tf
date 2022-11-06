# ssl.tf | SSL Configuration for Self Signed Certificate

// Web SSL
resource "tls_private_key" "web_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "web_registration" {
  account_key_pem = tls_private_key.web_private_key.private_key_pem
  email_address   = var.email_address
}

resource "acme_certificate" "web_certificate" {
  account_key_pem               = acme_registration.web_registration.account_key_pem
  common_name                   = aws_route53_zone.web_domain.name
  subject_alternative_names     = ["*.${aws_route53_zone.web_domain.name}"]
  revoke_certificate_on_destroy = true
  recursive_nameservers         = ["8.8.8.8:53"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_REGION            = var.aws_region
      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
      AWS_HOSTED_ZONE_ID    = aws_route53_zone.web_domain.zone_id
    }
  }


  depends_on = [
    acme_registration.web_registration,
    aws_route53_zone.web_domain
  ]
}

resource "aws_acm_certificate" "web_certificate" {
  certificate_body  = acme_certificate.web_certificate.certificate_pem
  private_key       = acme_certificate.web_certificate.private_key_pem
  certificate_chain = acme_certificate.web_certificate.issuer_pem
}
