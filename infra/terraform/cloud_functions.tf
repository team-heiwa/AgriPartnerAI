# Cloud Functions for data processing pipeline

# Cloud Function for processing uploaded files
resource "google_cloudfunctions2_function" "file_processor" {
  name     = "agripartner-file-processor-${var.environment}"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "process_uploaded_file"
    source {
      storage_source {
        bucket = google_storage_bucket.functions_source.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count = var.environment == "prod" ? 100 : 10
    min_instance_count = 0
    available_memory   = "1Gi"
    timeout_seconds    = 540
    
    environment_variables = {
      GCP_PROJECT_ID     = var.project_id
      GCS_INPUT_BUCKET   = google_storage_bucket.input_bucket.name
      GCS_OUTPUT_BUCKET  = google_storage_bucket.output_bucket.name
      GCS_TEMP_BUCKET    = google_storage_bucket.temp_bucket.name
      VERTEX_AI_LOCATION = var.region
      VERTEX_AI_MODEL    = var.vertex_ai_model
      ENVIRONMENT        = var.environment
    }
    
    service_account_email = google_service_account.pipeline_sa.email
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_RETRY"
    
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.input_bucket.name
    }
  }
}

# TODO: Add batch processing function later
# resource "google_cloudfunctions2_function" "batch_processor" {
#   # Will be implemented after event-triggered function is working
# }

# Storage bucket for Cloud Functions source code
resource "google_storage_bucket" "functions_source" {
  name          = "${var.project_id}-functions-source-${var.environment}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
}

# Placeholder source code for Cloud Functions
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.functions_source.name
  source = data.archive_file.function_source.output_path
}

data "archive_file" "function_source" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "${path.module}/../../backend/functions"
}

# Grant Eventarc service agent access to storage buckets
data "google_project" "project" {}

resource "google_storage_bucket_iam_member" "eventarc_gcs_access" {
  bucket = google_storage_bucket.input_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
}