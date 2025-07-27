variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
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

variable "vertex_ai_model" {
  description = "Vertex AI model to use for processing"
  type        = string
  default     = "gemini-1.5-flash"
}

variable "allow_public_access" {
  description = "Allow public access to Cloud Run services"
  type        = bool
  default     = true
}

variable "custom_domain" {
  description = "Custom domain for frontend"
  type        = string
  default     = ""
}

variable "backend_custom_domain" {
  description = "Custom domain for backend API"
  type        = string
  default     = ""
}