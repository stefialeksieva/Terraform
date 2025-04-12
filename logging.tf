resource "aws_ssm_document" "ec2_cloudwatch_config" {
  name          = "CloudWatchConfig"
  document_type = "Command"
  content       = <<EOF
{
  "schemaVersion": "2.2",
  "description": "CloudWatch Logs configuration for EC2 instance",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "configureCloudWatchLogs",
      "inputs": {
        "runCommand": [
          "yum install -y awslogs",
          "service awslogs start",
          "chkconfig awslogs on",
          "echo '[general]' >> /etc/awslogs/awslogs.conf",
          "echo 'state_file = /var/lib/awslogs/state' >> /etc/awslogs/awslogs.conf",
          "echo '[logs]' >> /etc/awslogs/awslogs.conf",
          "echo 'log_group_name = /aws/ec2/wordpress-instance-logs' >> /etc/awslogs/awslogs.conf",
          "echo 'log_stream_name = wordpress-instance-stream' >> /etc/awslogs/awslogs.conf",
          "service awslogs restart"
        ]
      }
    }
  ]
}
EOF
}

# Attach the EC2 CloudWatch configuration to the instances in the Auto Scaling Group
resource "aws_ssm_association" "ec2_cloudwatch_association" {
  name             = aws_ssm_document.ec2_cloudwatch_config.name
  targets {
    key    = "tag:Name"
    values = ["wordpress-instance"]
  }
  association_name = "WordPressEC2Logs"
}

