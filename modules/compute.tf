# Public instance
resource "aws_instance" "Bastion-host" {
  ami           = "ami-0e731c8a588258d0d"  # Specify your AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "Privakey"         # Specify your key pair name
  security_groups = [aws_security_group.bastion-sg.id]

  tags = {
    Name = "Bastion-host"
  }
}

# Private instance
resource "aws_instance" "private-instance" {
  ami           = "ami-0e731c8a588258d0d"  # Specify your AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = "Privakey"       # Specify your key pair name
  security_groups = [aws_security_group.private-sg.id]

  tags = {
    Name = "Private"
  }
}