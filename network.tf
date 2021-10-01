data "aws_availability_zones" "available" {
  state = "available"
  # exclude_names  = ["us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f", ]
}

# data "aws_subnet_ids" "private" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Tier = "Private"
#   }
# }

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${format("%s-vpc", var.project)}"
    Project = var.project
  }
}

# Create Public Subnet inside VPC
resource "aws_subnet" "pub_sub" {
  vpc_id                  = aws_vpc.main.id
  count                   = "${length(data.aws_availability_zones.available.names)}"
  cidr_block              = "10.0.${10+count.index}.0/24"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${format("%s-pub-sub-%03d", var.project, count.index + 1)}"
    Tier = "Public"
    Project = var.project
  }
}

# Create Private Subnet inside VPC
resource "aws_subnet" "prv_sub" {
  vpc_id                  = aws_vpc.main.id
  count                   = "${length(data.aws_availability_zones.available.names)}"
  cidr_block              = "10.0.${50+count.index}.0/24"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${format("%s-prv-sub-%03d", var.project, count.index + 1)}"
    Tier = "Private"
    Project = var.project
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${format("%s-igw", var.project)}"
    Project = var.project
  }
}

# Setup Route Table for pub_sub
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${format("%s-pub-rt", var.project)}"
    Project = var.project
  }
}

resource "aws_route_table_association" "rt_assoc" {
  count          =  "${length(data.aws_availability_zones.available.names)}"
  subnet_id      =  "${element(aws_subnet.pub_sub.*.id, count.index)}"
  route_table_id = aws_route_table.pub_rt.id
}

# Create Elastic IP
resource "aws_eip" "nat_eip" {
  vpc = true
  count = "${length(data.aws_availability_zones.available.names)}"

  tags = {
    Name = "${format("%s-nat-eip-%03d", var.project, count.index + 1)}"
    Project = var.project
  }
}

# Create NAT Gateway for prv_sub
resource "aws_nat_gateway" "ngw" {
  count         =  "${length(data.aws_availability_zones.available.names)}"
  allocation_id =  aws_eip.nat_eip[count.index].id
  subnet_id     =  "${element(aws_subnet.pub_sub.*.id, count.index)}"

  tags = {
    Name = "${format("%s-ngw-%03d", var.project, count.index + 1)}"
    Project = var.project
  }
}

# Setup Route Table for prv_sub
resource "aws_route_table" "prv_rt" {
  vpc_id = aws_vpc.main.id
  count           =  "${length(data.aws_availability_zones.available.names)}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  }

  tags = {
    Name = "${format("%s-prv-rt-%03d", var.project, count.index + 1)}"
    Project = var.project
  }
}

resource "aws_route_table_association" "prv_rt_assoc" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.prv_sub.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.prv_rt.*.id, count.index)}"
}
