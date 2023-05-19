#Instance Role
resource "aws_iam_role" "ssm_role" {
  name = "${format("%s-ssm-role", var.project)}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name    = "${format("%s-ssm-role", var.project)}"
    Project = var.project
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${format("%s-ssm-profile", var.project)}"
  role = "${aws_iam_role.ssm_role.id}"
  tags = {
    Name    = "${format("%s-ssm-profile", var.project)}"
    Project = var.project
  }
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "ssm_attach1" {
  name       = "${format("%s-ssm-attachment", var.project)}"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ssm_attach2" {
  name       = "${format("%s-ssm-attachment", var.project)}"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_ssm_parameter" "cwagent_config" {
  name  = "${format("%s-cwagent-config", var.project)}"
  type  = "String"
  value = file("cwagent_config.json")
}
