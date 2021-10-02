# data "aws_ssm_parameter" "linux_latest_ami" {
#   name   = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#   region = var.region
# }

resource "aws_instance" "jump_box" {
  # ami           = data.aws_ssm_parameter.linux_latest_ami.value
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id              = aws_subnet.pub_sub[0].id
  vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.bastion_sg.id]

  tags = {
    Project = var.project
    Name = "bastion"
  }
}

resource "aws_instance" "app_instance" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id              = aws_subnet.prv_sub[0].id
  vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.app_sg.id]
  count         = var.app_instance_count
  user_data     = "${file("install_httpd.sh")}"
  tags = {
    Project = var.project
    Name = "${format("app-server-%03d", count.index + 1)}"
  }
}

#Creating ELB
resource "aws_elb" "app_elb" {
  name = "${format("%s-elb", var.project)}"
  security_groups = [aws_security_group.general_sg.id, aws_security_group.elb_sg.id, aws_security_group.app_sg.id]
  subnets = aws_subnet.pub_sub.*.id
  # availability_zones = data.aws_availability_zones.available.names
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/index.html"
  }
  
  instances                   = aws_instance.app_instance.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300
  tags = {
    Name = "${format("%s-elb", var.project)}"
  }
}

# Creating Launch Configuration
# resource "aws_launch_configuration" "hub_app" {
#   image_id               = data.aws_ssm_parameter.linux_latest_ami.value
#   instance_type          = var.instance_type
#   security_groups        = [aws_security_group.app_sg.id]
#   key_name               = var.key_name
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p 8080 &
#               EOF
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Creating AutoScaling Group
# resource "aws_autoscaling_group" "hub_app" {
#   launch_configuration = aws_launch_configuration.hub_app.id
#   availability_zones = data.aws_availability_zones.available.names
#   min_size = 2
#   max_size = 10
#   load_balancers = [aws_elb.hub_app.name]
#   health_check_type = "ELB"
#   tag {
#     key = "Name"
#     value = "hub-app-asg"
#     propagate_at_launch = true
#   }
# }