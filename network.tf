resource "aws_internet_gateway" "redis" {
	vpc_id = "${aws_vpc.redis.id}"
}

# Public subnets
resource "aws_subnet" "subnet_pub" {
  vpc_id = "${aws_vpc.redis.id}"
  cidr_block = "${lookup(var.cidr_blocks_pub, concat("zone", count.index))}"
  availability_zone = "${lookup(var.zones, concat("zone", count.index))}"
  map_public_ip_on_launch = true
  count = 3
}

# Routing table for public subnets

resource "aws_route_table" "route-table-public" {
	vpc_id = "${aws_vpc.redis.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.redis.id}"
	}
}

resource "aws_route_table_association" "route-assoc-public" {
	subnet_id = "${element(aws_subnet.subnet_pub.*.id, count.index)}"
	route_table_id = "${aws_route_table.route-table-public.id}"
    count = 3
}

# Private subnets

resource "aws_subnet" "subnet_priv" {
  vpc_id = "${aws_vpc.redis.id}"
  cidr_block = "${lookup(var.cidr_blocks_priv, concat("zone", count.index))}"
  availability_zone = "${lookup(var.zones, concat("zone", count.index))}"
  count = 3
}

# Routing table for private subnets

resource "aws_route_table" "route-table-private" {
	vpc_id = "${aws_vpc.redis.id}"

	route {
		cidr_block = "0.0.0.0/0"
		instance_id = "${aws_instance.nat.id}"
	}
}

resource "aws_route_table_association" "route-assoc-private" {
	subnet_id = "${element(aws_subnet.subnet_priv.*.id, count.index)}"
	route_table_id = "${aws_route_table.route-table-private.id}"
    count = 3
}
