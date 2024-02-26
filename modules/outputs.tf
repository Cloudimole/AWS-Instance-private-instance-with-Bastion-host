# IP address
output "Bastion_ip" {
    value = aws_instance.Bastion-host.public_ip
}