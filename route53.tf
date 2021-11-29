data "aws_route53_zone" "hosted_zone" {
  name         = var.app_hosted_dns
  private_zone = false
}

resource "aws_route53_record" "bastion" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = format("%s.%s", var.bastion_host_prefix, var.app_hosted_dns)
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jump_box.public_ip]
}

resource "aws_route53_record" "api" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = format("%s.%s", var.app_dns_prefix, var.app_hosted_dns)
  type    = "A"

  alias {
    name                   = aws_elb.app_elb.dns_name
    zone_id                = aws_elb.app_elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = format("%s.%s", var.app_dns_prefix, var.app_hosted_dns)
  validation_method = "DNS"

  tags = {
    Project = var.project
    Name    = format("cert_%s.%s", var.app_dns_prefix, var.app_hosted_dns)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
