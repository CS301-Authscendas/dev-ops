resource "aws_service_discovery_private_dns_namespace" "service_discovery_dns" {
  name        = var.app_name
  description = "${var.app_name} DNS Namespace"
  vpc         = aws_vpc.aws_vpc.id
}

resource "aws_service_discovery_service" "discovery_service" {
  for_each = var.microservices
  name     = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery_dns.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 5
  }
}

