#this is to return the alb dns name

output "alb_dns_name" {
  value = aws_lb.cloud_watch_alb.dns_name
}
