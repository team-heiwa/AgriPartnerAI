# Service account for pipeline processor
resource "google_service_account" "pipeline_sa" {
  account_id   = "pipeline-processor-${var.environment}"
  display_name = "Pipeline Processor Service Account (${var.environment})"
  description  = "Service account for GCS to LLM pipeline processing"
}

# IAM roles for service account
resource "google_project_iam_member" "pipeline_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/aiplatform.user",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/artifactregistry.writer",
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Grant service account access to buckets
resource "google_storage_bucket_iam_member" "input_bucket_access" {
  bucket = google_storage_bucket.input_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

resource "google_storage_bucket_iam_member" "output_bucket_access" {
  bucket = google_storage_bucket.output_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

resource "google_storage_bucket_iam_member" "temp_bucket_access" {
  bucket = google_storage_bucket.temp_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# Service account key for local development
resource "google_service_account_key" "pipeline_sa_key" {
  service_account_id = google_service_account.pipeline_sa.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# Frontend service account
resource "google_service_account" "frontend_sa" {
  account_id   = "frontend-${var.environment}"
  display_name = "Frontend Service Account (${var.environment})"
  description  = "Service account for Next.js frontend"
}

# Frontend service account roles
resource "google_project_iam_member" "frontend_roles" {
  for_each = toset([
    "roles/run.invoker",
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.frontend_sa.email}"
}