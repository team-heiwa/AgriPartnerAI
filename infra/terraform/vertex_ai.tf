# Vertex AI endpoint configuration
resource "google_vertex_ai_endpoint" "pipeline_endpoint" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "pipeline-endpoint-${var.environment}"
  display_name = "Pipeline Processing Endpoint"
  description  = "Endpoint for LLM processing in pipeline"
  location     = var.region
}

# Note: Gemini models are accessed via API, not deployed endpoints
# This file is placeholder for any custom model deployments if needed