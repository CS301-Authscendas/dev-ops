# ssl.tf | SSL Configuration for Self Signed Certificate

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = aws_route53_zone.domain.name
  subject_alternative_names = ["*.${aws_route53_zone.domain.name}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_REGION            = var.aws_region
      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
      AWS_HOSTED_ZONE_ID    = aws_route53_zone.domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}

resource "aws_acm_certificate" "certificate" {
  certificate_body  = acme_certificate.certificate.certificate_pem
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_chain = acme_certificate.certificate.issuer_pem
}
