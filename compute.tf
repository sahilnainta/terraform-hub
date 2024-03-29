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

# Url to find list of AMIs using below filters
# https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#Images:visibility=public-images;ownerAlias=amazon;rootDeviceType=ebs;virtualization=hvm;imageName=amzn2-ami-hvm-*;architecture=x86_64;v=3;$case=tags:false%5C,client:false;$regex=tags:false%5C,client:false

resource "aws_instance" "jump_box" {
  ami                    = var.bastion_ami != "" ? var.bastion_ami : data.aws_ami.amazon_linux_latest.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.pub_sub[0].id
  vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.bastion_sg.id]

  tags = {
    Project = var.project
    Name    = "bastion"
  }

  lifecycle {
    create_before_destroy = true
  }

  ## This step is still not working to upload file

  provisioner "file" {
    source        = "${format(".ssh/%s.pem", var.key_name)}"
    destination   = "/home/ec2-user/.ssh/app-key.pem"
    
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = local_file.my_key_file.content
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/app-key.pem",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = local_file.my_key_file.content
      host        = self.public_ip
    }
  }
}
