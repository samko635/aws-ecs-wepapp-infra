####################################
# Data
####################################
data "aws_availability_zones" "available" {}

####################################
# VPC & Subnets
####################################
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "main_public_1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "main_public_1"
    Tier = "Public"
  }
}
resource "aws_subnet" "main_public_2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "main_public_2"
    Tier = "Public"
  }
}
resource "aws_subnet" "main_public_3" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "main_public_3"
    Tier = "Public"
  }
}
resource "aws_subnet" "main_private_1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "main_private_1"
    Tier = "Private"
  }
}
resource "aws_subnet" "main_private_2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "main_private_2"
    Tier = "Private"
  }
}
resource "aws_subnet" "main_private_3" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.1.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "main_private_3"
    Tier = "Private"
  }
}

####################################
# Gateways
####################################
# Internet GW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
  }
}

# Public NAT GW
resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.main_public_1.id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.main_igw]
}
resource "aws_eip" "nat_gateway_eip" {
  vpc = true
}

####################################
# Route tables
####################################
resource "aws_route_table" "main_public_rt" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_public_route_table"
  }
}

resource "aws_route_table" "main_private_rt" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_nat.id
  }

  tags = {
    Name = "main_private_route_table"
  }
}

# route associations
resource "aws_route_table_association" "main_public_1_a" {
  subnet_id = "${aws_subnet.main_public_1.id}"
  route_table_id = "${aws_route_table.main_public_rt.id}"
}
resource "aws_route_table_association" "main_public_2_b" {
  subnet_id = "${aws_subnet.main_public_2.id}"
  route_table_id = "${aws_route_table.main_public_rt.id}"
}
resource "aws_route_table_association" "main_public_3_c" {
  subnet_id = "${aws_subnet.main_public_3.id}"
  route_table_id = "${aws_route_table.main_public_rt.id}"
}
resource "aws_route_table_association" "main_private_1_a" {
  subnet_id = "${aws_subnet.main_private_1.id}"
  route_table_id = "${aws_route_table.main_private_rt.id}"
}
resource "aws_route_table_association" "main_private_2_b" {
  subnet_id = "${aws_subnet.main_private_2.id}"
  route_table_id = "${aws_route_table.main_private_rt.id}"
}
resource "aws_route_table_association" "main_private_3_c" {
  subnet_id = "${aws_subnet.main_private_3.id}"
  route_table_id = "${aws_route_table.main_private_rt.id}"
}