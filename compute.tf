# data "aws_ssm_parameter" "linux_latest_ami" {
#   name   = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#   region = var.region
# }

resource "aws_instance" "jump_box" {
  # ami           = data.aws_ssm_parameter.linux_latest_ami.value
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.pub_sub[0].id
  vpc_security_group_ids = [aws_security_group.general_sg.id, aws_security_group.bastion_sg.id]

  tags = {
    Project = var.project
    Name    = "bastion"
  }
}

# resource "aws_instance" "app_instance" {
#   ami           = var.ami
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
