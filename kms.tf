# kms.tf | Key Management Service Configuration

resource "aws_kms_key" "jwt_signing_key" {

  description              = "${var.app_name}-1"
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
  // TODO: Mention this feature in the presentation
  #   enable_key_rotation      = true
  #   multi_region = true
  tags = {
    Name        = "${var.app_name}-1"
    Environment = var.app_environment
  }
}

resource "aws_kms_alias" "jwt_signing_key_spare" {
  name          = "alias/${var.app_name}-1"
  target_key_id = aws_kms_key.jwt_signing_key.id
}

resource "aws_kms_key" "spare_jwt_signing_key" {
  description              = "${var.app_name}-2"
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
  // TODO: Mention this feature in the presentation
  #   enable_key_rotation      = true
  #   multi_region = true
  tags = {
    Name        = "${var.app_name}-2"
    Environment = var.app_environment
  }
}

resource "aws_kms_alias" "spare_jwt_signing_key" {
  name          = "alias/${var.app_name}-2"
  target_key_id = aws_kms_key.spare_jwt_signing_key.id
}
