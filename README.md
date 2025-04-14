# 🌐 WordPress on AWS with Terraform

This project provisions a scalable, secure, and highly available **WordPress** website on **AWS** using **Terraform**.

## 🧱 Architecture Overview

This infrastructure includes:

- **Amazon EC2 Auto Scaling Group** for WordPress instances.
- **Amazon RDS** (MySQL) for persistent WordPress database storage.
- **Application Load Balancer (ALB)** for traffic distribution.
- **Route 53** for DNS management.
- **ACM (SSL Certificate)** for HTTPS traffic.
- **CloudWatch Alarms** for CPU utilization monitoring.
- **CloudWatch Logs** and **SSM** for logging and configuration management.

## 📁 File Structure

| File              | Purpose |
|-------------------|---------|
| `provider.tf`     | AWS provider config and SSH key pair creation |
| `variables.tf`    | Input variables for customization |
| `ec2.tf`          | EC2 launch template and Auto Scaling Group |
| `elb.tf`          | ALB, target groups, listeners, and ACM |
| `rds.tf`          | RDS MySQL database and subnet group |
| `dns.tf`          | Route 53 DNS and certificate validation records |
| `cloudwatch.tf`   | CloudWatch metric alarm for EC2 CPU |
| `logging.tf`      | CloudWatch log setup via SSM Document |
| `security.tf`     | Security groups for EC2, RDS, and ALB |
| `outputs.tf`      | Useful post-deployment outputs |
| `user_data.tpl`   | Bootstrapping script for WordPress EC2 instances |
| `vpc.tf`          | VPC and networking configuration using module |

## 🚀 Getting Started

### Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- AWS CLI (configured)
- A registered domain in Route 53
- IAM permissions to manage EC2, RDS, ALB, ACM, SSM, and Route 53

### Deployment Steps

1. **Clone the repo**  
   ```bash
   git clone [https://github.com/stefialeksieva/Terraform]
   cd Terraform
