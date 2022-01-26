#Instance Role
resource "aws_iam_role" "ssm_role" {
  name = "hub-ssm-role"
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
    Name    = "${format("%s-app-lb", var.project)}"
    Project = var.project
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "hub-ssm-profile"
  role = "${aws_iam_role.ssm_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "hub_ssm_attach1" {
  name       = "hub-ssm-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "hub_ssm_attach2" {
  name       = "hub-ssm-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_ssm_parameter" "cwagent_config" {
  name  = "hub-cwagent-config"
  type  = "String"
  value = file("cwagent_config.json")
}
