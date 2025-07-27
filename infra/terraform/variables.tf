variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "input_bucket_retention_days" {
  description = "Number of days to retain files in input bucket"
  type        = number
  default     = 30
}

variable "output_bucket_retention_days" {
  description = "Number of days to retain files in output bucket"
  type        = number
  default     = 90
}