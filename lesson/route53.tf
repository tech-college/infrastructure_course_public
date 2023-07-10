# Host zone
locals {
  host_zone_id   = "YOURE-ZON-ID"
  host_zone_name = "YOUR-DOMAIN-NAME"
}

# DNS record
resource "aws_route53_record" "example" {
  zone_id = local.host_zone_id
  name    = local.host_zone_name
  type    = "A"

  alias {
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.example.name
}
