output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "input_bucket_name" {
  description = "Name of the input bucket"
  value       = google_storage_bucket.input_bucket.name
}

output "output_bucket_name" {
  description = "Name of the output bucket"
  value       = google_storage_bucket.output_bucket.name
}

output "temp_bucket_name" {
  description = "Name of the temporary processing bucket"
  value       = google_storage_bucket.temp_bucket.name
}

output "service_account_email" {
  description = "Email of the pipeline service account"
  value       = google_service_account.pipeline_sa.email
}

output "service_account_key" {
  description = "Base64 encoded service account key (handle with care!)"
  value       = google_service_account_key.pipeline_sa_key.private_key
  sensitive   = true
}

# Cloud Run service URLs
output "backend_api_url" {
  description = "URL of the backend API Cloud Run service"
  value       = google_cloud_run_service.backend_api.status[0].url
}

output "frontend_url" {
  description = "URL of the frontend Cloud Run service"
  value       = google_cloud_run_service.frontend.status[0].url
}

# Frontend service account
output "frontend_service_account_email" {
  description = "Email of the frontend service account"
  value       = google_service_account.frontend_sa.email
}

# Cloud Functions URLs (disabled for now)
# output "file_processor_function_url" {
#   description = "URL of the file processor Cloud Function"
#   value       = google_cloudfunctions2_function.file_processor.url
# }

# output "batch_processor_function_url" {
#   description = "URL of the batch processor Cloud Function"
#   value       = google_cloudfunctions2_function.batch_processor.url
# }

# Custom domains (if configured)
output "frontend_custom_domain" {
  description = "Custom domain for frontend (if configured)"
  value       = var.custom_domain != "" ? var.custom_domain : null
}

output "backend_custom_domain" {
  description = "Custom domain for backend API (if configured)"
  value       = var.backend_custom_domain != "" ? var.backend_custom_domain : null
}