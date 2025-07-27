# Required: Your GCP Project ID
project_id = "agripartnerai"

# Required: GCP Region
region = "asia-southeast1"

# Required: Environment
environment = "dev"

# Optional: Vertex AI model configuration
vertex_ai_model = "gemini-1.5-flash"

# Optional: Public access (set to false for production)
allow_public_access = true

# Optional: Custom domains (leave empty if not using)
custom_domain = ""
backend_custom_domain = ""

# Optional: Bucket retention settings
input_bucket_retention_days = 30
output_bucket_retention_days = 90