provider "aws" {
  region = "us-east-1"
  profile = "consul"
}

#-------------- Key-Pair --------------#
resource "aws_key_pair" "consul_key_pair" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


#-------------- AWS Instances --------------#
# Server 1
resource "aws_instance" "consul_instance_server_a" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.server_security_group}"]
  subnet_id = "${var.private_subnet_a}"

  tags{
    Name = "consul_instance_server_a"
    Project = "consul"
    Type = "server"
  }
}

# Server 2
resource "aws_instance" "consul_instance_server_b" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.server_security_group}"]
  subnet_id = "${var.private_subnet_b}"

  tags{
    Name = "consul_instance_server_b"
    Project = "consul"
    Type = "server"
  }
}

# Server 3
resource "aws_instance" "consul_instance_server_c" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.server_security_group}"]
  subnet_id = "${var.private_subnet_c}"

  tags{
    Name = "consul_instance_server_c"
    Project = "consul"
    Type = "server"
  }
}

# Client 1
resource "aws_instance" "consul_instance_client_a" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.client_security_group}"]
  subnet_id = "${var.public_subnet_a}"

  tags{
    Name = "consul_instance_client_a"
    Project = "consul"
    Type = "client"
  }
}