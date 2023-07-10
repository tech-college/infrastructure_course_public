# locals from route53.tf
# SSL certificate
resource "aws_acm_certificate" "example" {
  domain_name               = local.host_zone_name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# SSL certificate DNS records
resource "aws_route53_record" "example_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = local.host_zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# SSL certificate validation wait
resource "aws_acm_certificate_validation" "example" {
  for_each        = aws_route53_record.example_certificate
  certificate_arn = aws_acm_certificate.example.arn
  validation_record_fqdns = [
    aws_route53_record.example_certificate[each.key].fqdn
  ]
}
