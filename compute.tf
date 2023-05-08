# data "aws_ssm_parameter" "linux_latest_ami" {
#   name   = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#   region = var.region
# }

data "aws_ami" "amazon_linux_latest" {
  # executable_users = ["self"]
  # name_regex       = "^myami-\\d{3}"
  owners             = ["amazon"]
  most_recent        = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jump_box" {
  ami                    = data.aws_ami.amazon_linux_latest.id
  # ami                    = var.bastion_ami
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.pub_sub[0].id
  vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.bastion_sg.id]

  tags = {
    Project = var.project
    Name    = "bastion"
  }

  provisioner "file" {
    source        = "${format("~/.ssh/%s.pem", var.key_name)}"
    destination   = "~/.ssh/app-key.pem"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${format("~/.ssh/%s.pem", var.key_name)}")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/app-key.pem",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${format("~/.ssh/%s.pem", var.key_name)}")
      host        = self.public_ip
    }
  }
}

# resource "aws_instance" "app_instance" {
#   ami           = data.aws_ami.amazon_linux_latest.id
#   instance_type = "t2.micro"
#   monitoring    = true
#   key_name      = var.key_name
#   subnet_id              = aws_subnet.prv_sub[0].id
#   vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.app_sg.id]
#   count         = var.app_instance_count
#   user_data     = "${file("install_httpd.sh")}"
#   tags = {
#     Project = var.project
#     Name = "${format("app-server-%03d", count.index + 1)}"
#   }
# }
