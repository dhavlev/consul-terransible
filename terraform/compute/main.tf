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
# Client 1
resource "aws_instance" "consul_instance_client_b" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.client_security_group}"]
  subnet_id = "${var.public_subnet_b}"

  tags{
    Name = "consul_instance_client_b"
    Project = "consul"
    Type = "client"
  }
}

#-------------- ELB --------------#
resource "aws_elb" "consul_elb" {

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ../aws_hosts 

[consul-servers]
consul-server-bootstrap ansible_host=${aws_instance.consul_instance_server_a.public_ip}
consul-server-1 ansible_host=${aws_instance.consul_instance_server_b.public_ip}
consul-server-2 ansible_host=${aws_instance.consul_instance_server_c.public_ip}

[consul-clients]
consul-client-1 ansible_host=${aws_instance.consul_instance_client_a.public_ip}
consul-client-2 ansible_host=${aws_instance.consul_instance_client_b.public_ip}

[consul:children]
consul-servers
consul-clients
EOF
EOD
  }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.consul_instance_server_a.id} ${aws_instance.consul_instance_server_b.id} ${aws_instance.consul_instance_server_c.id} ${aws_instance.consul_instance_client_a.id} ${aws_instance.consul_instance_client_b.id} --profile ${var.aws_profile} && cd .. && ansible-playbook -i aws_hosts master-install-consul.yaml --tags 'setup'"
  }
  name = "consul-elb"
  subnets = ["${var.public_subnet_a}", "${var.public_subnet_b}"]
  instances = ["${aws_instance.consul_instance_client_a.id}", "${aws_instance.consul_instance_client_b.id}"]
  security_groups = ["${var.elb_security_group}"]

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "3"
    target              = "TCP:8500"
    interval            = "30"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags {
    Name = "consul_elb"
    Project = "consul"
  }
}

resource "aws_lb_cookie_stickiness_policy" "consul_elb_policy" {
  name                     = "consul-elb-policy"
  load_balancer            = "${aws_elb.consul_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}