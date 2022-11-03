# variables.tf | Auth and Application variables

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "aws_profile" {
  type        = string
  description = "AWS Credentials Profile"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_replica_region" {
  type        = string
  description = "Alternate AWS Region"
}

variable "aws_mq_username" {
  type        = string
  description = "Username for RabbitMQ"
}

variable "aws_mq_password" {
  type        = string
  description = "Password for RabbitMQ"
}

variable "aws_ses_email" {
  type        = string
  description = "Email Address for AWS SES"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}

variable "app_domain" {
  type        = string
  description = "Application Domain Name"
}

variable "email_address" {
  type        = string
  description = "Email Address for SSL Registration"
}

variable "web_subnets_1a" {
  description = "List of public subnets for Availability Zone (1a)"
  type        = string
}

variable "web_subnets_1b" {
  description = "List of public subnets for Availability Zone (1b)"
  type        = string
}

variable "authentication_subnets_1a" {
  description = "List of private subnets for Availability Zone (1a)"
  type        = string
}

variable "authentication_subnets_1b" {
  description = "List of private subnets for Availability Zone (1a)"
  type        = string
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
    cluster          = string
    hostPort         = number
    containerPort    = number
    indivdualCpu     = number
    individualMemory = number
    totalCpu         = number
    totalMemory      = number
  }))
}
