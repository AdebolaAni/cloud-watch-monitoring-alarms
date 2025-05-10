# creatre a security group for the application load balancer

resource "aws_security_group" "alb_security_group" {
  name        = "cloud_watch_alb_SG"
  description = "enable http/https access on port 80/443"
  vpc_id      = aws_vpc.cloud_watch_vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud_watch_alb_SG"
  }
}

# create security group for the web server
# terraform aws create security group
resource "aws_security_group" "cloud_watch_web_server_sg" {
  name        = "cloud-watch-sg"
  description = "Allow Internet access to the web server http port 80"
  vpc_id      = aws_vpc.cloud_watch_vpc.id
  ingress {
    description = "Allow HTTP access from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-watch-web-server-SG"
  }
}

