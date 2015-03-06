output "redis-ip" {
    value = ["${aws_instance.redis-server.*.private_ip}"]
}