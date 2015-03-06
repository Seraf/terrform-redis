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

variable "redis_port" {
	default = "6379"
}

variable "redis_sentinel_port" {
	default = "26379"
}

variable "ssh_port" {
	default = "26379"
}


variable "ssh_user" {
	default = "admin"
}

variable "aws_redis_instance_type" {
	default = "t2.micro"
}

variable "aws_debian_ami" {
	default = "ami-e7e66a90"
}

variable "key_path" {}

variable "key_name" {
    default = "deployer-key"
}

variable "key_public" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoDK2UxD3sWX1JVvMsx1GZm1WyzMH5kHAaEZLTc+EKKthuzrRL7eU3s78Dbk/epI6wuMA3PndEdxe8l5sYEWpgxrkkeCwI4dp6l1HELzfMGZCScpAHB/o1nEPGZhMSt6urMWCXsztzkMwR4BUetog8n8ss+qsYh8M70QSy007P2x3Lcyc+n44BFibLUssD2z8B9NwKp9AYlNKjfDkX7X9IWAig9MDvrAO7gW4b0PfB9EopHjMqSh267jS8S17R9TQirFqp2EkR9ultfoCzDFOZVhdetKJwnknF/srOcgpQKGgp/Bsu4iKE54hD2eY4AhoAKnD6M/++48mgq500svap seraf@tagada-laptopwork"
}

variable "redis_server_count" {
    default = "3"
}

variable "aws_vpc_redis" {}

variable "aws_security_group_bastion" {}

variable "aws_subnet_subnet_priv" {}

variable "aws_instance_bastion_public_ip" {}
