output "bastion_ip" {
  value = aws_instance.jump_box.public_ip
}

output "bastion_dns" {
  value = aws_route53_record.bastion.name
}

# output "app_instance_ip" {
#     value = ["${aws_instance.app_instance.*.private_ip}"]
# }

output "ssh_key_path" {
  value = local_file.my_key_file.filename
}

# output "elb_dns_name" {
#   value = aws_elb.app_elb.dns_name
# }

output "lb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "app_dns_name" {
  value = aws_route53_record.api.name
}

output "staging_app_dns_name" {
  value = aws_route53_record.staging_api.name
}

output "qa_app_dns_name" {
  value = aws_route53_record.qa_api.name
}

output "dev_app_dns_name" {
  value = aws_route53_record.dev_api.name
}