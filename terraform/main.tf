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

  instance_type = "${var.instance_type}"
  server_security_group = "${module.network.server_security_group}"
  client_security_group = "${module.network.client_security_group}"

  public_subnet_a = "${module.network.public_subnet_a}
  public_subnet_b = "${module.network.public_subnet_b}
  public_subnet_c = "${module.network.public_subnet_c}
  private_subnet_a = "${module.network.private_subnet_a}
  private_subnet_b = "${module.network.private_subnet_b}
  private_subnet_c = "${module.network.private_subnet_c}
}*/