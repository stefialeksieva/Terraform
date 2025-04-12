data "template_file" "user_data" {
  template = file("user_data.tpl")

  vars = {
    db_name     = aws_db_instance.wordpress.db_name
    db_user     = aws_db_instance.wordpress.username
    db_password = aws_db_instance.wordpress.password
    db_host     = aws_db_instance.wordpress.address
    admin_user  = var.admin_user
    admin_password = var.admin_password
    admin_email = var.admin_email
    auto_login_token = var.auto_login_token
  }
}

resource "aws_launch_template" "wordpress" {
  name_prefix   = "wordpress-"
  image_id      = "ami-00ac244ee0ad9050d" # Amazon Linux 2
  instance_type = var.instance_type
  key_name      = aws_key_pair.wordpress_key.key_name

 network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

# Ensure this block in ec2.tf is correct and is the only one.
resource "aws_autoscaling_group" "wordpress_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = module.vpc.public_subnets

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.wordpress_target_group.arn]  # Automatically registers instances with the target group
  health_check_type = "ELB"

  health_check_grace_period = 300  # Set this to an appropriate value (e.g., 5 minutes)

  tag {
    key                 = "Name"
    value               = "wordpress-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "wordpress_asg_target_tracking" {
  name                   = "wordpress-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name

  target_tracking_configuration {
    target_value = 50.0  # Maintain 50% CPU utilization

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

