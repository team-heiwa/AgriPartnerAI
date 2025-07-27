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