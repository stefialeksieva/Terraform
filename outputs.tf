output "wordpress_url" {
  value       = "https://wordpress.stefankaa.com"
  description = "Your WordPress site is ready!"
  depends_on  = [null_resource.wait_for_targets_healthy]
}

output "wordpress_alb_home_url_redirects_to_domain" {
  value       = "https://${aws_lb.wordpress_lb.dns_name} → https://wordpress.stefankaa.com"
  description = "The ALB DNS will automatically redirect to your custom domain."
}

output "wordpress_alb_home_url" {
  value = "https://${aws_lb.wordpress_lb.dns_name}/"
  description = "WordPress home page. Access the home page using this URL to see the WordPress site."
  depends_on  = [null_resource.wait_for_targets_healthy]
}

output "wordpress_auto_login_url_secure" {
  value = "https://${var.subdomain}.${var.domain_name}/wp-auto-login.php?token=${var.auto_login_token}"
  description = "Click on this link to securely auto-login to the WordPress admin console using a token."
  depends_on  = [null_resource.wait_for_targets_healthy]
}

