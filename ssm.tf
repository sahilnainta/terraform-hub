#Instance Role
resource "aws_iam_role" "ssm_role" {
  name = "club-ssm-role"
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
  name = "club-ssm-profile"
  role = "${aws_iam_role.ssm_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "club_ssm_attach1" {
  name       = "club-ssm-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "club_ssm_attach2" {
  name       = "club-ssm-attachment"
  roles      = [aws_iam_role.ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_ssm_parameter" "cwagent_config" {
  name  = "club-cwagent-config"
  type  = "String"
  value = file("cwagent_config.json")
}

// TODO: Hardcoded name 'club-xxxx' needs to be picked from terraform.tfvars
