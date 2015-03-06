# ELB Part
resource "aws_security_group" "elb-sentinel" {
	name = "elb-sentinel"
	description = "Allow sentinel flow"
    vpc_id = "${var.aws_vpc_redis}"

	ingress {
		from_port = "${var.redis_sentinel_port}"
		to_port = "${var.redis_sentinel_port}"
		protocol = "tcp"
		security_groups = ["${var.aws_security_group_bastion}"]
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
  subnets = ["${var.aws_subnet_subnet_priv}"]
}

# Redis Part

resource "aws_security_group" "redis" {
	name = "redis"
	description = "Allow redis flow"
    vpc_id = "${var.aws_vpc_redis}"

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
		security_groups = ["${var.aws_security_group_bastion}"]
	}

	tags {
        Name = "sg-redis"
    }
}

resource "aws_security_group" "sentinel" {
	name = "sentinel"
	description = "Allow sentinel flow"
	vpc_id = "${var.aws_vpc_redis}"

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
	subnet_id = "${element(var.aws_subnet_subnet_priv, count.index)}"
	count = "${var.redis_server_count}"
	connection {
		user        = "${var.ssh_user}"
		key_file    = "${var.key_path}"
		host        = "${var.aws_instance_bastion_public_ip}"
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