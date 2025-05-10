# We want to create an application load balancer

resource "aws_lb" "cloud_watch_alb" {
  name               = "cloud-watch-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]

  subnet_mapping {
    subnet_id = aws_subnet.cloud_watch_public_subnet_az1a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.cloud_watch_public_subnet_az1b.id
  }
  enable_deletion_protection = false

  tags = {
    Name = "cloud-watch-alb"
  }
}

# now we move on to create a target group

resource "aws_lb_target_group" "cloud_watch_TG" {
  name        = "cloud-watch-TG"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloud_watch_vpc.id


  health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

#next we register the patty moore web server with the target group

resource "aws_lb_target_group_attachment" "cloud_watch_target_group_attachement" {
target_group_arn = aws_lb_target_group.cloud_watch_TG.arn
target_id        = aws_instance.cloud_watch_web_server.id
port             = 80
}

#next we create a listner on port 80 with re-direct action
# terraform aws create listener

resource "aws_lb_listener" "cloud_watch_alb_http_listener" {
  load_balancer_arn = aws_lb.cloud_watch_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create a listener on port 443 with forward action (HTTPS)

resource "aws_lb_listener" "cloud_watch_alb_https_listener" {
  load_balancer_arn = aws_lb.cloud_watch_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cloud_watch_TG.arn
  }
}