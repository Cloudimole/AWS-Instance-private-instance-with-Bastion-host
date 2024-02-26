# VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = {
    Name = "privpc"
  }
}

# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyIGW"
  }
}

# Subnets (Public and Private)
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MyPublic_Subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MyPrivate_Subnet"
  }
}

# Key pair
#resource "aws_key_pair" "bastionkey" {
  #key_name   = "bastionkey"
  #public_key = file(var.public_key)
#} 

# Route table
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "main-public"
  }
}

resource "aws_route_table_association" "main-public-route" {
  route_table_id = aws_route_table.main-public.id
  subnet_id = aws_subnet.public_subnet.id
}

# Security groups
resource "aws_security_group" "bastion-sg" {
  name        = "Bastion_allow_ssh"
  description = "Allow all SSH and all outgoing"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  description = "Allow ping from all IPs"
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-allow-all"
  }
}

resource "aws_security_group" "private-sg" {
  name        = "Private_allow_only_Bastion"
  description = "Allow only Bastion SSH and all outgoing"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]
  }
  
  ingress {
  cidr_blocks = ["10.0.1.0/24"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  from_port   = 8
  to_port     = 0
  protocol    = "icmp"
  description = "Allow ping from bastion host"
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}