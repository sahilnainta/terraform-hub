data "aws_route53_zone" "app" {
  name         = "32nd.com"
  private_zone = false
}

resource "aws_route53_record" "api" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.app.zone_id
  name    = format("%s.%s", var.app_dns_prefix, var.app_hosted_dns)
  type    = "A"

  alias {
    name                   = aws_elb.app_elb.dns_name
    zone_id                = aws_elb.app_elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "bastion" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.app.zone_id
  name    = format("%s.%s", var.bastion_host_prefix, var.app_hosted_dns)
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jump_box.public_ip]
}