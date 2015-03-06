# Bastion

resource "aws_security_group" "bastion" {
	name = "bastion"
	description = "Allow SSH traffic from the internet"
    vpc_id = "${aws_vpc.redis.id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags {
        Name = "sg-bastion"
    }
}

resource "aws_instance" "bastion" {
	ami = "${var.aws_debian_ami}"
	instance_type = "${var.aws_nat_instance_type}"
	key_name = "${var.key_name}"
	security_groups = ["${aws_security_group.bastion.id}"]
	subnet_id = "${aws_subnet.subnet_pub.0.id}"
	tags {
        Name = "bastion"
    }

    connection {
		user     = "${var.ssh_user}"
		key_file = "${var.key_path}"
	}

	provisioner "file" {
		source      = "${var.key_path}"
		destination = "/home/admin/.ssh/id_rsa"
	}

  	provisioner "remote-exec" {
		inline = [
		    "chmod 600 /home/admin/.ssh/id_rsa",
		    "sudo apt-get update",
		]
    }
}

output "bastion-ip" {
    value = "${aws_instance.bastion.public_ip}"
}
