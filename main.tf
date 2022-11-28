terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.my_access_key
  secret_key = var.my_secret_key
}

#Availability zone
data "aws_availability_zones" "available" {
  state = "available"
}

#Creating EC2 instance - Jenkins server
resource "aws_instance" "jenkins_server" {
  ami = "ami-08c40ec9ead489470"

  subnet_id = aws_subnet.subnet_1.id

  instance_type = "t2.small"

  #associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.jenkins_sg.id}"]

  key_name = aws_key_pair.devops_kp.key_name

  user_data = file("install_jenkins.sh")

  #set tags
  tags = {
    Name = "jenkins_server"
  }
}

#Creating a keypair on AWS
resource "aws_key_pair" "devops_kp" {
  key_name = "devops_kp"

  public_key = file("devops_kp.pub")
}

#Creatin an Elastic IP for the server
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_server.id

  vpc = true

  #setting tags
  tags = {
    Name = "jenkins_eip"
  }
}

#Creating IAM role
resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks_cluster_role"
  assume_role_policy = file("assumerolepolicy.json")
}

#Policy attachment
resource "aws_iam_role_policy_attachment" "jumia-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "jumia-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# DB provisioning
resource "aws_db_instance" "postgresql" {
  depends_on             = [aws_security_group.db_sg]
  identifier             = var.identifier
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = var.engine_version[var.engine]
  instance_class         = var.instance_class
  name                   = var.db_name
  username               = var.username
  password               = var.password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.id
  skip_final_snapshot    = true

}

resource "aws_db_subnet_group" "main" {
  name        = "main"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
}

# Security Group 

#creating a security group for jenkins server
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security group for jenkins_sg and cluster"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "Allow all traffic through port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable SSH access only on port 22
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 80/443 from anywhere"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 1337 from anywhere"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable jenkins to talk to internet
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tag on sg
  tags = {
    Name = "jenkins_sg"
  }
}

#DB sg
resource "aws_security_group" "db_sg" {
  name        = "rds_sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "Allow 1337 to access port"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

#VPC setting

#creating a VPC called devops_vpc
resource "aws_vpc" "devops_vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "devops_vpc"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops_igw"
  }
}

#creating the public route table
resource "aws_route_table" "devops_public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
}