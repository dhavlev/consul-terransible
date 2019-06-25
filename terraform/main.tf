provider "aws" {
  region = "us-east-1"
  profile = "consul"
}

module "network" {
  source = "./network"
}

/*module "compute" {
  source = "./compute"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  public_key_path = "${var.public_key_path}"
  aws_profile = "${var.aws_profile}"

  web_instance_type = "${var.web_instance_type}"
  web_security_group = "${module.network.web_security_group}"

  web_subnet_a = "${module.network.web_subnet_a}"
  web_subnet_b = "${module.network.web_subnet_b}"
}*/