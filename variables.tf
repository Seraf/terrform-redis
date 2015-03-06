variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_path" {}

variable "region" {
    default = "eu-west-1"
}

variable "zones" {
    default = {
        zone0 = "eu-west-1a"
        zone1 = "eu-west-1b"
        zone2 = "eu-west-1c"
    }
}

variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "vpc_dns_support" {
    default = "true"
}

variable "vpc_dns_hostnames" {
    default = "true"
}

variable "cidr_blocks_pub" {
    default = {
        zone0 = "10.0.0.0/24"
        zone1 = "10.0.1.0/24"
        zone2 = "10.0.2.0/24"
    }
}

variable "cidr_blocks_priv" {
    default = {
        zone0 = "10.0.3.0/24"
        zone1 = "10.0.4.0/24"
        zone2 = "10.0.5.0/24"
    }
}


variable "ssh_user" {
	default = "admin"
}

variable "aws_nat_ami" {
	default = "ami-30913f47"
}

variable "aws_nat_instance_type" {
	default = "m1.small"
}

variable "aws_bastion_instance_type" {
	default = "t2.micro"
}

variable "aws_debian_ami" {
	default = "ami-e7e66a90"
}

variable "key_name" {
    default = "deployer-key"
}

variable "key_public" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoDK2UxD3sWX1JVvMsx1GZm1WyzMH5kHAaEZLTc+EKKthuzrRL7eU3s78Dbk/epI6wuMA3PndEdxe8l5sYEWpgxrkkeCwI4dp6l1HELzfMGZCScpAHB/o1nEPGZhMSt6urMWCXsztzkMwR4BUetog8n8ss+qsYh8M70QSy007P2x3Lcyc+n44BFibLUssD2z8B9NwKp9AYlNKjfDkX7X9IWAig9MDvrAO7gW4b0PfB9EopHjMqSh267jS8S17R9TQirFqp2EkR9ultfoCzDFOZVhdetKJwnknF/srOcgpQKGgp/Bsu4iKE54hD2eY4AhoAKnD6M/++48mgq500svap seraf@tagada-laptopwork"
}
