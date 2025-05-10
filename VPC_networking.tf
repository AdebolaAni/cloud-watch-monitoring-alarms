# This is to create a vpc named patty_moore
resource "aws_vpc" "cloud_watch_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloud_watch_vpc"
  }
}

# This code is to create an internet gateway named patty_moore_IGW
resource "aws_internet_gateway" "cloud_watch_igw" {
  vpc_id = aws_vpc.cloud_watch_vpc.id

  tags = {
    Name = "cloud_watch_igw"
  }
}

#This code is to create a public subnet in az1a
resource "aws_subnet" "cloud_watch_public_subnet_az1a" {
  vpc_id                  = aws_vpc.cloud_watch_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.cloud_watch_vpc,
  aws_internet_gateway.cloud_watch_igw]

  tags = {
    Name = "cloud_watch_public_subnet_az1a"
  }
}

#This code is to create a public subnet in az1b
resource "aws_subnet" "cloud_watch_public_subnet_az1b" {
  vpc_id                  = aws_vpc.cloud_watch_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.cloud_watch_vpc,
  aws_internet_gateway.cloud_watch_igw]

  tags = {
    Name = "cloud_watch_public_subnet_az1b"
  }
}

#This code is to create a private subnet in az1a
resource "aws_subnet" "cloud_watch_private_subnet_az1a" {
  vpc_id                  = aws_vpc.cloud_watch_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.cloud_watch_vpc,
  aws_internet_gateway.cloud_watch_igw]

  tags = {
    Name = "cloud_watch_private_subnet_az1a"
  }
}

#This code is to create a private subnet in az1b
resource "aws_subnet" "cloud_watch_private_subnet_az1b" {
  vpc_id                  = aws_vpc.cloud_watch_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  depends_on = [aws_vpc.cloud_watch_vpc,
  aws_internet_gateway.cloud_watch_igw]

  tags = {
    Name = "cloud_watch_private_subnet_az1b"
  }
}

#This is to create an elastic IP for the NAT gateway
resource "aws_eip" "cloud_watch_eip_for_nat_gateway" {
  domain = "vpc"

  tags = {
    Name = "cloud_watch_eip_for_nat_gateway"
  }
}

#Next is to create a Nat-gateway
resource "aws_nat_gateway" "cloud_watch_nat_gateway" {
  allocation_id = aws_eip.cloud_watch_eip_for_nat_gateway.id
  subnet_id     = aws_subnet.cloud_watch_public_subnet_az1a.id

  tags = {
    Name = "cloud_watch_nat_gateway"
  }
  depends_on = [aws_internet_gateway.cloud_watch_igw,
  aws_subnet.cloud_watch_public_subnet_az1a]
}
#now we go ahead and create a public route table
resource "aws_route_table" "cloud_watch_public_rt" {
  vpc_id = aws_vpc.cloud_watch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud_watch_igw.id
  }
  tags = {
    Name = "cloud_watch_public_rt"
  }
}

#Next, we associate the public rt with the public subnet in az1a
resource "aws_route_table_association" "public_subnet_association_az1a" {
  subnet_id      = aws_subnet.cloud_watch_public_subnet_az1a.id
  route_table_id = aws_route_table.cloud_watch_public_rt.id
}

#Next, we associate the public rt with the public subnet in az1b
resource "aws_route_table_association" "public_subnet_association_az1b" {
  subnet_id      = aws_subnet.cloud_watch_public_subnet_az1b.id
  route_table_id = aws_route_table.cloud_watch_public_rt.id
}

#now we go ahead and create a private route table
resource "aws_route_table" "cloud_watch_private_rt" {
  vpc_id = aws_vpc.cloud_watch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cloud_watch_nat_gateway.id
  }
  tags = {
    Name = "cloud_watch_public_rt"
  }
}

#Next, we associate the private rt with the private subnet in az1a
resource "aws_route_table_association" "private_subnet_association_az1a" {
  subnet_id      = aws_subnet.cloud_watch_private_subnet_az1a.id
  route_table_id = aws_route_table.cloud_watch_private_rt.id
}

#Next, we associate the private rt with the private subnet in az1b
resource "aws_route_table_association" "private_subnet_association_az1b" {
  subnet_id      = aws_subnet.cloud_watch_private_subnet_az1b.id
  route_table_id = aws_route_table.cloud_watch_private_rt.id
}