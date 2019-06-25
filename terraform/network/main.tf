data "aws_availability_zones" "data_az" {
  
}

#-------------- VPC --------------#
resource "aws_vpc" "consul_vpc" {
  cidr_block = "192.168.0.0/16"
    
  tags{
      Name = "consul"
      Project = "consul"
  }
}

#-------------- Internet Gateway --------------#
resource "aws_internet_gateway" "consul_igw" {
  vpc_id ="${aws_vpc.consul_vpc.id}"
  
  tags{
      Name = "consul"
      Project = "consul"
    }
}

#-------------- Route Tables --------------#
resource "aws_route_table" "consul_rt_public" {
  vpc_id = "${aws_vpc.consul_vpc.id}"
  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.consul_igw.id}"
  }

  tags{
      Name = "consul_rt_public"
      Project = "consul"
  }
}

#-------------- Subnets --------------#
resource "aws_subnet" "consul_sub_public_a" {
  vpc_id = "${aws_vpc.consul_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[0]}"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  
  tags{
      Name = "consul_sub_public_a"
      Project = "consul"
  }
}

resource "aws_subnet" "consul_sub_public_b" {
  vpc_id = "${aws_vpc.consul_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[1]}"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  
  tags{
      Name = "consul_sub_public_b"
      Project = "consul"
  }
}

resource "aws_subnet" "consul_sub_public_c" {
  vpc_id = "${aws_vpc.consul_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[2]}"
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true
  
  tags{
      Name = "consul_sub_public_c"
      Project = "consul"
  }
}

#-------------- Route Subnet Association --------------#
resource "aws_route_table_association" "consul_rta_public_a" {
  route_table_id = "${aws_route_table.consul_rt_public.id}"
  subnet_id = "${aws_subnet.consul_sub_public_a.id}"
}

resource "aws_route_table_association" "consul_rta_public_b" {
  route_table_id = "${aws_route_table.consul_rt_public.id}"
  subnet_id = "${aws_subnet.consul_sub_public_b.id}"
}

resource "aws_route_table_association" "consul_rta_public_c" {
  route_table_id = "${aws_route_table.consul_rt_public.id}"
  subnet_id = "${aws_subnet.consul_sub_public_c.id}"
}

#-------------- Security Groups --------------#

resource "aws_security_group" "consul_sg_client" {
  name = "web_access"
  description = "default access to instances over 22, 8301, 8500, 8600"
  vpc_id = "${aws_vpc.consul_vpc.id}"

  tags{
      Name = "consul_sg_public"
      Project = "consul"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #dns
  ingress{
      from_port = 8600
      to_port = 8600
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #http
  ingress{
      from_port = 8500
      to_port = 8500
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #dns
  ingress{
      from_port = 8301
      to_port = 8301
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consul_sg_server" {
  name = "web_access"
  description = "default access to instances over 22, 8301, 8300, 8600"
  vpc_id = "${aws_vpc.consul_vpc.id}"

  tags{
      Name = "consul_sg_public"
      Project = "consul"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #dns
  ingress{
      from_port = 8600
      to_port = 8600
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #lan serf
  ingress{
      from_port = 8301
      to_port = 8301
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #server rpc
  ingress{
      from_port = 8300
      to_port = 8300
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}






