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
   git clone https://github.com/stefialeksieva/Terraform
   cd Terraform

## ✅ Best Practices and Standards Used

This project follows AWS and Terraform best practices to ensure reliability, security, and maintainability:

### 🔒 Security
- Principle of Least Privilege for IAM roles and SSM access.
- Security Groups are tightly scoped (e.g., only ALB can reach EC2 on HTTP/HTTPS).
- Secrets (DB credentials) are managed via variables, and SSM Parameter Store can be integrated for better secret handling.
- SSL/TLS encryption enabled via **ACM certificates** and HTTPS listeners on ALB.

### ☁️ High Availability & Scalability
- EC2 instances are in an **Auto Scaling Group** across multiple Availability Zones.
- **ALB** ensures traffic distribution and failover.
- **RDS Multi-AZ deployment** can be enabled for production workloads.

### 🛠️ Infrastructure as Code (IaC)
- Entire setup is reproducible and version-controlled using **Terraform**.
- Separated modules and logical files (VPC, EC2, RDS, ALB, etc.) for clarity and maintainability.
- Variable usage and outputs make the code reusable and adaptable.

### 📊 Monitoring & Logging
- **CloudWatch Alarms** are configured to monitor EC2 CPU utilization.
- **SSM Agent** and **CloudWatch Logs** collect EC2 instance logs.
- Outputs include Log Group and Alarm ARN for integration with alerting systems.

### 🔁 Automation & Bootstrapping
- **User data** script automatically installs and configures WordPress on launch.
- Infrastructure is self-healing via Auto Scaling and Load Balancer health checks.

### 🌍 Domain & Routing
- Uses **Route 53** for DNS management.
- DNS validation with ACM ensures seamless SSL certificate provisioning.

### 📦 Modularity
- **VPC** setup uses a Terraform module for reusable networking.
- Future modules (e.g., for backups or WAF) can easily be added.

---

These practices make the deployment production-ready, secure by default, and easy to manage or extend.

