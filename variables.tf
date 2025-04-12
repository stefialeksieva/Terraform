variable "aws_region" {
  default = "eu-central-1"
}

variable "project_name" {
  default = "wordpress"
}

variable "key_pair_name" {
  default = "wordpress-key"
}

variable "domain_name" {
  default = "stefankaa.com"
}

variable "subdomain" {
  default = "wordpress"
}

variable "instance_type" {
  default = "t3.small"
}

variable "db_username" {
  default = "wordpressuser"
}

variable "db_password_length" {
  default = 16
}

variable "admin_user" {
  description = "Admin username for WordPress"
  type        = string
}

variable "admin_password" {
  description = "Admin password for WordPress"
  type        = string
}

variable "admin_email" {
  description = "Admin email for WordPress"
  type        = string
}

variable "auto_login_token" {
  description = "Secure token for auto login"
  type        = string
}

