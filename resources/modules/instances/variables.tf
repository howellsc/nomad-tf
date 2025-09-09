variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_subnet_name" {
  description = "VPC subnet name"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  # Default value
}

variable "name" {
  description = "Unique name which all of the resources will have prefixed"
  type        = string
}