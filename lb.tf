# Creating ALB

resource "aws_lb" "app_lb" {
  name               = format("%s-app-lb", var.project)
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.general_sg.id, aws_security_group.elb_sg.id, aws_security_group.app_sg.id]
  subnets         = aws_subnet.pub_sub.*.id

  idle_timeout                     = 100
  enable_cross_zone_load_balancing = true
  

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = format("%s-app-log-", var.project)
    enabled = true
  }

  tags = {
    Name    = "${format("%s-app-lb", var.project)}"
    Project = var.project
  }
}

resource "aws_lb_target_group" "app_servers" {
  name     = format("%s-app-lb-tg", var.project)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3 // Set 10 Seconds -> wait for this much time for response
    interval            = 30
    path                = "/index.html" // 1. Add /graphql endpoint
    port                = 80 // Change port to 443
  }

  tags = {
    Name    = "${format("%s-app-lb-tg", var.project)}"
    Project = var.project
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_servers.arn
  }
}

#Creating Launch Configuration
resource "aws_launch_configuration" "app_lc" {
  name_prefix     = format("%s-app-lc-", var.project)
  image_id        = var.app_ami != "" ? var.app_ami : data.aws_ami.amazon_linux_latest.id
  instance_type   = var.instance_type   
  security_groups = [aws_security_group.general_sg.id, aws_security_group.app_sg.id]
  key_name        = var.key_name
  iam_instance_profile = "${aws_iam_instance_profile.ssm_profile.id}"
  user_data       = var.app_ami != "" ? file("scripts/start_app.sh") : file("scripts/prepare_ami.sh") 
  lifecycle {
    create_before_destroy = true
  }
}

# Creating AutoScaling Group
resource "aws_autoscaling_group" "app_asg" {
  name              = format("%s-app-asg", var.project)
  min_size          = var.app_instance_count
  max_size          = 10
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.app_servers.arn]
  launch_configuration = aws_launch_configuration.app_lc.id
  vpc_zone_identifier  = aws_subnet.prv_sub.*.id

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
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