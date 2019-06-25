output "consul_vpc" {
  value = "${aws_vpc.consul_vpc.id}"
}

output "web_security_group" {
  value = "${aws_security_group.consul_sg_public.id}"
}

output "web_subnet_a" {
  value = "${aws_subnet.consul_sub_public_a.id}"
}

output "web_subnet_b" {
  value = "${aws_subnet.consul_sub_public_b.id}"
}

output "web_subnet_c" {
  value = "${aws_subnet.consul_sub_public_c.id}"
}