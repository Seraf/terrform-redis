module "redis" {
    source = "./redis"
    redis_server_count = 3
    aws_vpc_redis = "${aws_vpc.redis.id}"
    aws_security_group_bastion = "${aws_security_group.bastion.id}"
    aws_subnet_subnet_priv = "${aws_subnet.subnet_priv.*.id}"
    aws_instance_bastion_public_ip = "${aws_instance.bastion.public_ip}"
  	#depends_on = ["aws_instance.bastion", "null_resource.install-ansible"]
  	key_path = "${var.key_path}"
}

resource "null_resource" "install-ansible" {
	depends_on = ["aws_instance.bastion"]

	connection {
		user        = "${var.ssh_user}"
		key_file    = "${var.key_path}"
		host        = "${var.aws_instance_bastion_public_ip}"
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