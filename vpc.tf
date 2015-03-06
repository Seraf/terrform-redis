provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

resource "aws_vpc" "redis" {
	cidr_block           = "${var.vpc_cidr_block}"
	enable_dns_support   = "${var.vpc_dns_support}"
    enable_dns_hostnames = "${var.vpc_dns_hostnames}"
}

resource "aws_key_pair" "deploy_key" {
  key_name   = "${var.key_name}"
  public_key = "${var.key_public}"
}
