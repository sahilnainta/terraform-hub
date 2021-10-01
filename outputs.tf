output "bastion_ip" {
    value = aws_instance.jump_box.public_ip
}

output "app_instance_ip" {
    value = ["${aws_instance.app_instance.*.private_ip}"]
}

output "ssh_key_path" {
  value = local_file.my_key_file.filename
}

# output "elb_dns_name" {
#   value = aws_elb.hub_app.dns_name
# }