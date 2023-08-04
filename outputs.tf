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

output "staging1_app_dns_name" {
  value = aws_route53_record.staging1_api.name
}

output "qa1_app_dns_name" {
  value = aws_route53_record.qa1_api.name
}

output "dev1_app_dns_name" {
  value = aws_route53_record.dev1_api.name
}

output "redis_node_address" {
  value       = aws_elasticache_cluster.redis.cache_nodes[*].address
  description = "The address of the endpoint for the primary node in redis cluster, if the cluster mode is disabled."
}

output "redis_host_name" {
  value = aws_route53_record.redis.name
}

