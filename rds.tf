resource "random_password" "db_password" {
  length  = var.db_password_length
  special = false
}

resource "aws_db_instance" "wordpress" {
  identifier             = "wordpress-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = random_password.db_password.result
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "wordpress"
  publicly_accessible    = false
  multi_az               = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.wordpress_db_subnet.name
}

resource "aws_db_subnet_group" "wordpress_db_subnet" {
  name       = "wordpress-db-subnet"
  subnet_ids = module.vpc.private_subnets
}

