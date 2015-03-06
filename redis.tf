# ELB Part
resource "aws_security_group" "elb-sentinel" {
	name = "elb-sentinel"
	description = "Allow sentinel flow"
    vpc_id = "${aws_vpc.redis.id}"

	ingress {
		from_port = "${var.redis_sentinel_port}"
		to_port = "${var.redis_sentinel_port}"
		protocol = "tcp"
		security_groups = ["${aws_security_group.bastion.id}"]
	}

	tags {
        Name = "sg-elb-sentinel"
    }
}

resource "aws_elb" "redis-sentinel-internal-elb" {
  name = "redis-sentinel-internal-elb"
  listener {
    instance_port = "${var.redis_sentinel_port}"
    instance_protocol = "tcp"
    lb_port = "${var.redis_sentinel_port}"
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:${var.redis_sentinel_port}"
    interval = 30
  }

  instances = ["${aws_instance.redis-server.*.id}"]
  cross_zone_load_balancing = true
  internal = true
  subnets = ["${aws_subnet.subnet_priv.*.id}"]
}

# Redis Part

resource "aws_security_group" "redis" {
	name = "redis"
	description = "Allow redis flow"
    vpc_id = "${aws_vpc.redis.id}"

	ingress {
		from_port = "${var.redis_port}"
		to_port = "${var.redis_port}"
		protocol = "tcp"
		self = true
	}

	ingress {
		from_port = "${var.ssh_port}"
		to_port = "${var.ssh_port}"
		protocol = "tcp"
		security_groups = ["${aws_security_group.bastion.id}"]
	}

	tags {
        Name = "sg-redis"
    }
}

resource "aws_security_group" "sentinel" {
	name = "sentinel"
	description = "Allow sentinel flow"
	vpc_id = "${aws_vpc.redis.id}"

	ingress {
		from_port = "${var.redis_sentinel_port}"
		to_port = "${var.redis_sentinel_port}"
		protocol = "tcp"
		security_groups = ["${aws_security_group.elb-sentinel.id}"]
	}

	ingress {
		from_port = "${var.redis_sentinel_port}"
		to_port = "${var.redis_sentinel_port}"
		protocol = "tcp"
        self = true
	}

	tags {
        Name = "sg-sentinel"
    }
}

resource "aws_instance" "redis-server" {
	ami = "${var.aws_debian_ami}"
	instance_type = "${var.aws_redis_instance_type}"
	key_name = "${var.key_name}"
	security_groups = ["${aws_security_group.redis.id}", "${aws_security_group.sentinel.id}"]
	subnet_id = "${element(aws_subnet.subnet_priv.*.id, count.index)}"
	depends_on        = ["aws_instance.bastion", "null_resource.install-ansible"]
	count = "${var.redis_server_count}"
	connection {
		user        = "${var.ssh_user}"
		key_file    = "${var.key_path}"
		host        = "${var.aws_instance.bastion.public_ip}"
		script_path = "/tmp/redis-server-${count.index}.sh"
	}

	provisioner "file" {
		source      = "${path.module}/ansible/tasks/redis.yml"
		destination = "/home/admin/redis.yml"
	}

	provisioner "remote-exec" {
		inline = [
		    "sudo ansible-galaxy install debops.redis --force",
		    "sudo sh -c \"echo '${self.private_dns}' >> /etc/ansible/hosts\"",
		    "ansible-playbook -vvv -i /etc/ansible/hosts --sudo -l ${self.private_dns} redis.yml"
		]
    }

	tags {
        Name = "redis-server"
    }
}

resource "null_resource" "install-ansible" {
	depends_on = ["aws_instance.bastion"]

	connection {
		user        = "${var.ssh_user}"
		key_file    = "${var.key_path}"
		host        = "${aws_instance.bastion.public_ip}"
	}

 	provisioner "file" {
		source      = "${path.module}/ansible/ansible.cfg"
		destination = "/tmp/ansible.cfg"
	}

  	provisioner "remote-exec" {
		inline = [
			"sudo apt-get -y install python-pip python-dev",
			"sudo pip install ansible",
			"sudo mkdir /etc/ansible",
			"sudo mv /tmp/ansible.cfg /etc/ansible/ansible.cfg",
			"sudo sh -c 'echo \"[redis]\" >> /etc/ansible/hosts'",
		]
    }
}

output "redis-ip" {
    value = ["${aws_instance.redis-server.*.private_ip}"]
}