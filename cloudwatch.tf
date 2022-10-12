# cloudwatch.tf | Cloudwatch Configuration

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.app_name}-logs"

  tags = {
    Application = var.app_name
    Environment = var.app_environment
  }
}
