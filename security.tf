# Create Security Groups
resource "aws_security_group" "general_sg" {
  description = "HTTP/HTTPS egress to anywhere"
  vpc_id      = aws_vpc.main.id
  name        = format("%s-general-sg", var.project)
  tags = {
    Name    = "${format("%s-general-sg", var.project)}"
    Project = var.project
  }
}

resource "aws_security_group" "bastion_sg" {
  description = "SSH ingress to Bastion and SSH egress to App"
  vpc_id      = aws_vpc.main.id
  name        = format("%s-bastion-sg", var.project)
  tags = {
    Name    = "${format("%s-bastion-sg", var.project)}"
    Project = var.project
  }
}

resource "aws_security_group" "app_sg" {
  description = "SSH ingress from Bastion and HTTP ingress from ELB"
  # description = "SSH ingress from Bastion, HTTP ingress from ELB & mongo ingress from Anywhere"
  vpc_id      = aws_vpc.main.id
  name        = format("%s-app-sg", var.project)
  tags = {
    Name    = "${format("%s-app-sg", var.project)}"
    Project = var.project
  }
}

resource "aws_security_group" "elb_sg" {
  description = "HTTP/HTTPS ingress from Anywhere"
  vpc_id      = aws_vpc.main.id
  name        = format("%s-elb-sg", var.project)
  tags = {
    Name    = "${format("%s-elb-sg", var.project)}"
    Project = var.project
  }
}

# Configure Egress rules on Security Groups
resource "aws_security_group_rule" "out_http" {
  type              = "egress"
  description       = "Allow HTTP egress to anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.general_sg.id
}

resource "aws_security_group_rule" "out_https" {
  type              = "egress"
  description       = "Allow HTTPS egress to anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.general_sg.id
}

resource "aws_security_group_rule" "out_mongo_app_to_anywhere" {
  type              = "egress"
  description       = "Allow mongo egress from App to anywhere"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "out_ssh_bastion_to_app" {
  type                     = "egress"
  description              = "Allow SSH egress on Bastion to App"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id        = aws_security_group.bastion_sg.id
}

# resource "aws_security_group_rule" "out_http_app" {
#   type              = "egress"
#   description       = "Allow HTTP egress from App to anywhere"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.app_sg.id
# }

# Configure Ingress rules on Security Groups
resource "aws_security_group_rule" "in_ssh_bastion_from_anywhere" {
  type              = "ingress"
  description       = "Allow SSH ingress to Bastion from anywhere"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "in_ssh_app_from_bastion" {
  type                     = "ingress"
  description              = "Allow SSH ingress to App from Bastion"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.app_sg.id
}
resource "aws_security_group_rule" "in_http_elb_from_anywhere" {
  type              = "ingress"
  description       = "Allow HTTP ingress from Anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "in_https_elb_from_anywhere" {
  type              = "ingress"
  description       = "Allow HTTPS ingress from Anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "in_http_app_from_elb" {
  type                     = "ingress"
  description              = "Allow HTTP ingress to App from ELB"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.elb_sg.id
  security_group_id        = aws_security_group.app_sg.id
}
