variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  default     = "10.0.2.0/24"
}

variable "instance_type_web" {
  description = "The instance type for the web server."
  default     = "t2.micro"
}

variable "instance_type_db" {
  description = "The instance type for the database server."
  default     = "t2.micro"
}

variable "key_name" {
  description = "E-Commerce"
}

variable "web_ami_id" {
  description = "ami-0a0e5d9c7acc336f1"
}

variable "db_ami_id" {
  description = "ami-0a0e5d9c7acc336f1"
}

variable "web_server_name" {
  description = "The name for the web server instance."
  default     = "Web-Server"
}

variable "db_server_name" {
  description = "The name for the database server instance."
  default     = "Database-Server"
}
