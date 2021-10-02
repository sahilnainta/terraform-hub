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

#Creating Launch Configuration
resource "aws_launch_configuration" "app_lc" {
  name            = format("%s-app-lc", var.project)
  image_id        = var.ami
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
  name                 = format("%s-app-asg", var.project)
  min_size          = 2
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