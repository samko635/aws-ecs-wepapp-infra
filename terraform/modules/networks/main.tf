# Internet VPC
resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags = {
        Name = "main"
    }
}


# Subnets
resource "aws_subnet" "main-public-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-southeast-2a"

    tags = {
        Name = "main-public-1"
        Tier = "Public"
    }
}
resource "aws_subnet" "main-public-2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-southeast-2b"

    tags = {
        Name = "main-public-2"
        Tier = "Public"
    }
}
resource "aws_subnet" "main-public-3" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-southeast-2c"

    tags = {
        Name = "main-public-3"
        Tier = "Public"
    }
}
resource "aws_subnet" "main-private-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-southeast-2a"

    tags {
        Name = "main-private-1"
        Tier = "Private"
    }
}
resource "aws_subnet" "main-private-2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.5.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-southeast-2b"

    tags {
        Name = "main-private-2"
        Tier = "Private"
    }
}
resource "aws_subnet" "main-private-3" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.1.6.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-southeast-2c"

    tags = {
        Name = "main-private-3"
        Tier = "Private"
    }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags = {
        Name = "main"
    }
}

# route tables
resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }

    tags = {
        Name = "main-public-1"
    }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.main-public-1.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}
resource "aws_route_table_association" "main-public-2-a" {
    subnet_id = "${aws_subnet.main-public-2.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}
resource "aws_route_table_association" "main-public-3-a" {
    subnet_id = "${aws_subnet.main-public-3.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}
