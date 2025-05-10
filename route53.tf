# get hosted zone details
# terraform aws data hosted zone
data "aws_route53_zone" "hosted_zone" {
  name = "angelfestuspharmacy.com"
}

# create a record set in route 53
# terraform aws route 53 record
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_lb.cloud_watch_alb.dns_name
    zone_id                = aws_lb.cloud_watch_alb.zone_id
    evaluate_target_health = true
  }
}