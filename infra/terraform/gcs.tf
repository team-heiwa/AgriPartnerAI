# Input bucket for media files
resource "google_storage_bucket" "input_bucket" {
  name          = "${var.project_id}-pipeline-input-${var.environment}"
  location      = var.region
  force_destroy = var.environment != "prod"
  
  uniform_bucket_level_access = true
  
  lifecycle_rule {
    condition {
      age = var.input_bucket_retention_days
    }
    action {
      type = "Delete"
    }
  }
  
  versioning {
    enabled = true
  }
}

# Output bucket for processed results
resource "google_storage_bucket" "output_bucket" {
  name          = "${var.project_id}-pipeline-output-${var.environment}"
  location      = var.region
  force_destroy = var.environment != "prod"
  
  uniform_bucket_level_access = true
  
  lifecycle_rule {
    condition {
      age = var.output_bucket_retention_days
    }
    action {
      type = "Delete"
    }
  }
  
  versioning {
    enabled = true
  }
}

# Temporary bucket for processing
resource "google_storage_bucket" "temp_bucket" {
  name          = "${var.project_id}-pipeline-temp-${var.environment}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}