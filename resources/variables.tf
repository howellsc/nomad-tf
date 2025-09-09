variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-west1"
  # Default value
}

variable "zone" {
  description = "The zone where resources will be created"
  type        = string
  default     = "us-west1-a"
  # Default value
}

variable "name" {
  description = "Unique name which all of the resources will have prefixed"
  type        = string
  default     = "howells"
}
