# kms.tf | Key Management Service Configuration

resource "aws_kms_key" "jwt_signing_key" {
  description              = "Custom JWT Signing Key"
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
  // TODO: Mention this feature in the presentation
  #   enable_key_rotation      = true
  #   multi_region = true
  tags = {
    Name        = "${var.app_name}-jwt-signing-key"
    Environment = var.app_environment
  }
}
