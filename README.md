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

This project adheres to AWS and Terraform best practices for building a secure, scalable, and maintainable WordPress deployment:

### 🔒 Security
- **Principle of Least Privilege** applied through tightly scoped security groups.
- **Network isolation** with dedicated security groups for EC2, RDS, and ALB.
- **Encrypted HTTPS traffic** using ACM certificates and ALB listeners.

### ☁️ High Availability & Scalability
- **EC2 Auto Scaling Group** across multiple Availability Zones ensures fault tolerance.
- **RDS Multi-AZ** deployment provides high availability for the database layer.
- **Application Load Balancer (ALB)** distributes incoming traffic to healthy instances.

### 🛠️ Infrastructure as Code (IaC)
- Fully managed using **Terraform**, enabling reproducible, consistent deployments.
- **Logical separation** of infrastructure into dedicated files (e.g., `ec2.tf`, `rds.tf`, `vpc.tf`) for modularity and readability.
- Use of **variables** and **outputs** for better reusability and integration.

### 📊 Monitoring & Logging
- **CloudWatch Alarms** configured for EC2 instance CPU usage.
- **CloudWatch Logs** integrated via **SSM Document**, allowing centralized logging.

### 🔁 Automation & Bootstrapping
- **User data script** (`user_data.tpl`) automates WordPress installation and configuration on EC2 instances.
- EC2 instances are **self-healing** through health checks and auto scaling.

### 🌍 Domain & Routing
- **Route 53** used for DNS management and domain resolution.
- **DNS validation** automates SSL certificate provisioning via ACM.

---

## 🔮 Future Improvements

The following enhancements could further optimize and harden the infrastructure:

- Store sensitive values (e.g., DB passwords) in **SSM Parameter Store** or **Secrets Manager**.
- Add a **WAF (Web Application Firewall)** to the ALB for enhanced security.
- Integrate **backup policies** for RDS and EC2 volume snapshots.
- Use **Terraform modules** for more reusable and shareable components.


