variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet" {
  default = "10.0.1.0/24"
}

variable "security_group" {
  default = "jenkins_sg"
}

variable "my_ip" {
  description = "IP address to access server"
  sensitive   = false
}

#variable "vpc_id" {}

#DB variables sg_variables
variable "cidr_blocks" {
  default     = "0.0.0.0/0"
  description = "CIDR for sg"
}

variable "sg_name" {
  default     = "db_sg"
  description = "Tag Name for sg"
}

#DB variables DB main
variable "identifier" {
  default     = "jumia-postgre"
  description = "Identifier for my DB"
}

variable "storage" {
  default     = "20"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type is postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "14.2"
  }
}

variable "instance_class" {
  default     = "db.t4g.small"
  description = "Instance class"
}

variable "db_name" {
  default     = "jumia_phone_validator"
  description = "db name"
}

variable "username" {
  default     = "jumia"
  description = "User name"
}

variable "password" {
  type        = string
  description = "password, provide through ENV variables"
}

variable "my_access_key" {
  type        = string
  description = "enter access_key"
}

variable "my_secret_key" {
  type        = string
  description = "enter secret_access_key"
}
