data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "wordpress_dns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.wordpress_lb.dns_name]  # This now correctly references the load balancer
}

