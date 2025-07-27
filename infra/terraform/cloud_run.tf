# Cloud Run service for FastAPI backend
resource "google_cloud_run_service" "backend_api" {
  name     = "agripartner-backend-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        
        ports {
          container_port = 8080
        }
        
        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }
        
        env {
          name  = "GCP_REGION"
          value = var.region
        }
        
        env {
          name  = "GCS_INPUT_BUCKET"
          value = google_storage_bucket.input_bucket.name
        }
        
        env {
          name  = "GCS_OUTPUT_BUCKET"
          value = google_storage_bucket.output_bucket.name
        }
        
        env {
          name  = "GCS_TEMP_BUCKET"
          value = google_storage_bucket.temp_bucket.name
        }
        
        env {
          name  = "VERTEX_AI_LOCATION"
          value = var.region
        }
        
        env {
          name  = "VERTEX_AI_MODEL"
          value = var.vertex_ai_model
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        
        env {
          name  = "LOG_LEVEL"
          value = var.environment == "prod" ? "INFO" : "DEBUG"
        }
        
        env {
          name  = "ENABLE_CLOUD_LOGGING"
          value = "true"
        }
        
        resources {
          limits = {
            cpu    = var.environment == "prod" ? "2" : "1"
            memory = var.environment == "prod" ? "2Gi" : "1Gi"
          }
          requests = {
            cpu    = "0.5"
            memory = "512Mi"
          }
        }
      }
      
      service_account_name = google_service_account.pipeline_sa.email
      timeout_seconds      = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = var.environment == "prod" ? "1" : "0"
        "autoscaling.knative.dev/maxScale"      = var.environment == "prod" ? "20" : "5"
        "run.googleapis.com/cpu-throttling"     = "false"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Cloud Run service for Next.js frontend
resource "google_cloud_run_service" "frontend" {
  name     = "agripartner-frontend-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        
        ports {
          container_port = 3000
        }
        
        env {
          name  = "NEXT_PUBLIC_API_URL"
          value = google_cloud_run_service.backend_api.status[0].url
        }
        
        env {
          name  = "NEXT_PUBLIC_GCP_PROJECT_ID"
          value = var.project_id
        }
        
        env {
          name  = "NEXT_PUBLIC_ENVIRONMENT"
          value = var.environment
        }
        
        resources {
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
          requests = {
            cpu    = "0.25"
            memory = "256Mi"
          }
        }
      }
      
      timeout_seconds = 300
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = var.environment == "prod" ? "1" : "0"
        "autoscaling.knative.dev/maxScale"      = var.environment == "prod" ? "10" : "3"
        "run.googleapis.com/cpu-throttling"     = "true"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM for Cloud Run services
resource "google_cloud_run_service_iam_member" "backend_public_access" {
  count = var.allow_public_access ? 1 : 0
  
  service  = google_cloud_run_service.backend_api.name
  location = google_cloud_run_service.backend_api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "frontend_public_access" {
  count = var.allow_public_access ? 1 : 0
  
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Frontend to Backend access
resource "google_cloud_run_service_iam_member" "frontend_to_backend" {
  service  = google_cloud_run_service.backend_api.name
  location = google_cloud_run_service.backend_api.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

# Custom domain mapping (optional)
resource "google_cloud_run_domain_mapping" "frontend_domain" {
  count = var.custom_domain != "" ? 1 : 0
  
  location = var.region
  name     = var.custom_domain

  spec {
    route_name = google_cloud_run_service.frontend.name
  }
}

resource "google_cloud_run_domain_mapping" "backend_domain" {
  count = var.backend_custom_domain != "" ? 1 : 0
  
  location = var.region
  name     = var.backend_custom_domain

  spec {
    route_name = google_cloud_run_service.backend_api.name
  }
}