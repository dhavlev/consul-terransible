output "consul_vpc" {
  value = "${aws_vpc.consul_vpc.id}"
}

output "server_security_group" {
  value = "${aws_security_group.consul_sg_server.id}"
}

output "client_security_group" {
  value = "${aws_security_group.consul_sg_client.id}"
}

output "elb_security_group" {
  value = "${aws_security_group.consul_sg_elb.id}"
}

output "public_subnet_a" {
  value = "${aws_subnet.consul_sub_public_a.id}"
}

output "public_subnet_b" {
  value = "${aws_subnet.consul_sub_public_b.id}"
}

output "public_subnet_c" {
  value = "${aws_subnet.consul_sub_public_c.id}"
}

output "private_subnet_a" {
  value = "${aws_subnet.consul_sub_private_a.id}"
}

output "private_subnet_b" {
  value = "${aws_subnet.consul_sub_private_b.id}"
}

output "private_subnet_c" {
  value = "${aws_subnet.consul_sub_private_c.id}"
}