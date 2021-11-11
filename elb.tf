#Creating ELB
resource "aws_elb" "app_elb" {
  name            = format("%s-app-elb", var.project)
  security_groups = [aws_security_group.general_sg.id, aws_security_group.elb_sg.id, aws_security_group.app_sg.id]
  subnets         = aws_subnet.pub_sub.*.id
  # availability_zones = data.aws_availability_zones.available.names
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/index.html"
  }

  # instances                   = aws_instance.app_instance.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300
  tags = {
    Name = "${format("%s-app-elb", var.project)}"
  }
}

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

#Creating Launch Configuration
resource "aws_launch_configuration" "app_lc" {
  name_prefix            = format("%s-app-lc-", var.project)
  image_id        = data.aws_ami.amazon_linux_latest.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.general_sg.id, aws_security_group.app_sg.id]
  key_name        = var.key_name
  user_data       = file("install_httpd.sh")
  lifecycle {
    create_before_destroy = true
  }
}

# Creating AutoScaling Group
resource "aws_autoscaling_group" "app_asg" {
  name              = format("%s-app-asg", var.project)
  min_size          = var.app_instance_count
  max_size          = 10
  load_balancers    = [aws_elb.app_elb.name]
  health_check_type = "ELB"
  launch_configuration = aws_launch_configuration.app_lc.id
  vpc_zone_identifier  = aws_subnet.prv_sub.*.id
  # availability_zones = data.aws_availability_zones.available.names

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = format("%s-app-server", var.project)
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}

# Creating AutoScaling Policies
resource "aws_autoscaling_policy" "app_scale_up" {
  name                   = format("%s-app-scale-up", var.project)
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}
resource "aws_autoscaling_policy" "app_scale_down" {
  name                   = format("%s-app-scale-down", var.project)
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scaling app_asg based on cloudwatch metrics
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = format("%s-app-high-cpu", var.project)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = format("This metric monitors %s-app high cpu utilization", var.project)
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.app_scale_up.arn]
}
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = format("%s-app-low-cpu", var.project)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = format("This metric monitors %s-app low cpu utilization", var.project)
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.app_scale_down.arn]
}