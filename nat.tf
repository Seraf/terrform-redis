# NAT instance

resource "aws_security_group" "nat" {
	name        = "nat"
	description = "Allow services from the private subnet through NAT"
	vpc_id      = "${aws_vpc.redis.id}"

	ingress {
		from_port   = 0
		to_port     = 65535
		protocol    = "tcp"
		cidr_blocks = ["${var.vpc_cidr_block}"]
	}

    tags {
        Name = "sg-nat"
    }
}

resource "aws_instance" "nat" {
	ami                         = "${var.aws_nat_ami}"
	instance_type               = "${var.aws_nat_instance_type}"
	key_name                    = "${var.key_name}"
	security_groups             = ["${aws_security_group.nat.id}"]
	subnet_id                   = "${aws_subnet.subnet_pub.0.id}"
	associate_public_ip_address = true
	source_dest_check           = false
    tags {
        Name = "nat"
    }
}

resource "aws_eip" "nat" {
	instance = "${aws_instance.nat.id}"
	vpc      = true
}

output "nat-ip" {
    value = "${aws_eip.nat.public_ip}"
}