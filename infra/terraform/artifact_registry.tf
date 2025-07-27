# Artifact Registry for Docker images

resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "agripartner-images"
  description   = "Docker repository for AgriPartner application images"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-images"
    action = "DELETE"
    condition {
      older_than = "2592000s"  # 30 days
    }
  }
}