# Application Load Balancer (ALB)
resource "aws_lb" "wordpress_lb" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = {
    Name = "wordpress-lb"
  }
}

# Target Group for the ALB
resource "aws_lb_target_group" "wordpress_target_group" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}

# ACM Certificate Request
resource "aws_acm_certificate" "wordpress_certificate" {
  domain_name       = "${var.subdomain}.${var.domain_name}"  # e.g., wordpress.stefankaa.com
  validation_method = "DNS"

  tags = {
    Name = "wordpress-certificate"
  }
}

# DNS validation record (assumes single domain validation option)
resource "aws_route53_record" "wordpress_certificate_validation" {
  name    = element(tolist(aws_acm_certificate.wordpress_certificate.domain_validation_options), 0).resource_record_name
  type    = element(tolist(aws_acm_certificate.wordpress_certificate.domain_validation_options), 0).resource_record_type
  ttl     = 60
  records = [element(tolist(aws_acm_certificate.wordpress_certificate.domain_validation_options), 0).resource_record_value]

  zone_id = data.aws_route53_zone.primary.zone_id
}

# Wait for the certificate to be validated
resource "aws_acm_certificate_validation" "wordpress_certificate_validation" {
  certificate_arn         = aws_acm_certificate.wordpress_certificate.arn
  validation_record_fqdns = [aws_route53_record.wordpress_certificate_validation.fqdn]
}

# HTTP listener to redirect traffic to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.wordpress_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener for the Load Balancer
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.wordpress_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.wordpress_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_target_group.arn
  }
}

resource "null_resource" "wait_for_targets_healthy" {
  depends_on = [aws_lb_target_group.wordpress_target_group]

  provisioner "local-exec" {
    command = <<EOT
    echo "Waiting for instances to become healthy..."

    for i in {1..300}; do
      HEALTHY=$(aws elbv2 describe-target-health \
        --target-group-arn ${aws_lb_target_group.wordpress_target_group.arn} \
        --query 'TargetHealthDescriptions[*].TargetHealth.State' \
        --output text)

      if echo "$HEALTHY" | grep -q "healthy"; then
        echo "Instance is healthy!"
        exit 0
      else
        echo "Still waiting for healthy target..."
        sleep 10
      fi
    done

    echo "Instance did not become healthy in time."
    exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

