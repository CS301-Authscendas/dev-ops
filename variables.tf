# variables.tf | Auth and Application variables

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

# variable "aws_key_pair_name" {
#   type        = string
#   description = "AWS Key Pair Name"
# }

# variable "aws_key_pair_file" {
#   type = string
#   description = "AWS Key Pair File"
# }

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets_1a" {
  description = "List of public subnets for Availability Zone (1a)"
  type        = string
}

variable "public_subnets_1b" {
  description = "List of public subnets for Availability Zone (1b)"
  type        = string
}

variable "private_subnets_1a" {
  description = "List of private subnets for Availability Zone (1a)"
  type        = list(string)
}

variable "private_subnets_1b" {
  description = "List of private subnets for Availability Zone (1a)"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "clusters" {
  description = "List of clusters"
  type        = list(string)
}

variable "microservices" {
  description = "List of microservices"
  type = map(object({
    cluster       = string
    hostPort      = number
    containerPort = number
    indivdualCpu  = number
    totalMemory   = number
    totalCpu      = number
    totalMemory   = number
  }))
}

# variable "database_name" {
#   description = "Database Name"
#   type        = string
# }

# variable "database_password" {
#   description = "Database Password"
#   type        = string
# }
