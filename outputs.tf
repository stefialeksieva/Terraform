output "wordpress_url" {
  value       = "https://wordpress.stefankaa.com"
  description = "Your WordPress site is ready!"
  depends_on  = [null_resource.wait_for_targets_healthy]
}

