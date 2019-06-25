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
resource "aws_instance" "consul_instance_server_a" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.web_security_group}"]
  subnet_id = "${var.web_subnet_a}"

  tags{
    Name = "consul_instance_server_a"
    Project = "consul"
  }
}

resource "aws_instance" "consul_instance_server_b" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.web_security_group}"]
  subnet_id = "${var.web_subnet_b}"

  tags{
    Name = "consul_instance_server_b"
    Project = "consul"
  }
}

resource "aws_instance" "consul_instance_db" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.consul_key_pair.id}"
  vpc_security_group_ids = ["${var.db_security_group}"]
  subnet_id = "${var.db_subnet}"

  tags{
    Name = "consul_instance_db"
    Project = "consul"
  }
}

#-------------- ELB --------------#
resource "aws_elb" "consul_elb" {

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ../aws_hosts 

[dev-consul-servers]
dev-consul-server-1 ansible_host=${aws_instance.consul_instance_server_a.public_ip}
dev-consul-server-1 ansible_host=${aws_instance.consul_instance_server_b.public_ip}
dev-consul-server-1 ansible_host=${aws_instance.consul_instance_server_c.public_ip}

[dev-consul-clients]
dev-consul-client-1 ansible_host=${aws_instance.consul_instance_client_a.public_ip}

[dev-consul:children]
dev-consul-servers
dev-consul-clients

EOF
EOD
  }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.consul_instance_server_a.id} ${aws_instance.consul_instance_server_b.id} ${aws_instance.consul_instance_server_c.id} ${aws_instance.consul_instance_db.id} --profile ${var.aws_profile} && cd .. && ansible-playbook -i aws_hosts master-install-consul.yaml"
  }
  name = "consul-elb"
  subnets = ["${var.web_subnet_a}", "${var.web_subnet_b}"]
  instances = ["${aws_instance.consul_instance_server_a.id}", "${aws_instance.consul_instance_server_b.id}"]
  security_groups = ["${var.web_security_group}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "3"
    target              = "TCP:80"
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

resource "aws_lb_cookie_stickiness_policy" "consul_lb_policy" {
  name                     = "consul-lb-policy"
  load_balancer            = "${aws_elb.consul_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}
