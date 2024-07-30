provider "aws" {
  region = "<YOUR_AWS_REGION>"  # AWS region
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block = "<VPC_CIDR_BLOCK>"  # CIDR block for VPC
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "<PUBLIC_SUBNET_CIDR_BLOCK>"  # CIDR block for public subnet
  availability_zone = "<AVAILABILITY_ZONE>"  # Preferred AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "<PRIVATE_SUBNET_CIDR_BLOCK>"  # CIDR block for private subnet
  availability_zone = "<AVAILABILITY_ZONE>"  # Preferred AZ
  tags = {
    Name = "PrivateSubnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Create a NAT gateway
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "MyNATGateway"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Create route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create a security group for the instance
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "InstanceSG"
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for backend services
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "BackendSG"
  }

  ingress {
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance in the public subnet
resource "aws_instance" "web" {
  ami           = "<AMI_ID>"  # AMI ID
  instance_type = "<INSTANCE_TYPE>"  # The instance type
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.instance_sg.name]
  tags = {
    Name = "MyWebInstance"
  }

  # Optional: If you want to use key pair for SSH
  key_name = var.key_name
}

# Variables
variable "http_port" {
  description = "Port for HTTP traffic"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for HTTPS traffic"
  type        = number
  default     = 443
}

variable "ssh_port" {
  description = "Port for SSH traffic"
  type        = number
  default     = 22
}

variable "backend_port" {
  description = "Port for backend services"
  type        = number
  default     = 5432  # Example
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = ""  # SSH key pair name
}
