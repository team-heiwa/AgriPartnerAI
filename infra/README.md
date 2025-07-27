# AgriPartner AI Infrastructure

This directory contains Terraform configuration for deploying the AgriPartner AI infrastructure on Google Cloud Platform.

## Prerequisites

1. **Google Cloud Project**: Create a GCP project and enable billing
2. **Terraform**: Install Terraform >= 1.5.0
3. **Google Cloud SDK**: Install and authenticate with `gcloud auth application-default login`
4. **GCS Bucket for State**: Create a bucket for Terraform state storage

## Setup Steps

### 1. Authentication
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Create State Bucket
```bash
gsutil mb gs://your-project-terraform-state
gsutil versioning set on gs://your-project-terraform-state
```

### 3. Configure Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project settings
```

### 4. Update State Bucket
Edit `main.tf` and update the backend configuration:
```hcl
backend "gcs" {
  bucket = "your-project-terraform-state"  # Update this
  prefix = "terraform/state"
}
```

### 5. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

## Required Variables

- `project_id`: Your GCP project ID
- `region`: GCP region (default: us-central1)
- `environment`: Environment name (dev/staging/prod)

## Optional Variables

- `vertex_ai_model`: Vertex AI model to use (default: gemini-1.5-flash)
- `allow_public_access`: Allow public access to services (default: true)
- `custom_domain`: Custom domain for frontend
- `backend_custom_domain`: Custom domain for backend API
- `input_bucket_retention_days`: Input bucket retention (default: 30 days)
- `output_bucket_retention_days`: Output bucket retention (default: 90 days)

## Infrastructure Components

### Storage
- **Input Bucket**: For uploading raw files (images/audio)
- **Output Bucket**: For processed results
- **Temp Bucket**: For temporary processing files

### Compute
- **Cloud Run**: 
  - Backend API (FastAPI)
  - Frontend (Next.js)
- **Cloud Functions**:
  - File processor (triggered by GCS uploads)
  - Batch processor (HTTP triggered)

### AI/ML
- **Vertex AI**: For image and audio processing

### Security
- **Service Accounts**: Separate accounts for pipeline and frontend
- **IAM Roles**: Minimal required permissions
- **Private Keys**: For local development (stored securely)

## Outputs

After deployment, Terraform will output:
- Service URLs for backend and frontend
- Bucket names
- Service account emails
- Function URLs

## Development Workflow

1. **Local Development**: Use service account key for authentication
2. **Testing**: Deploy to dev environment first
3. **Production**: Use separate project/environment

## Security Notes

- Service account keys are sensitive - handle with care
- Enable audit logging in production
- Use custom domains with SSL certificates
- Restrict public access in production environments

## Troubleshooting

### Common Issues
1. **API Not Enabled**: Enable required APIs in GCP Console
2. **Permissions**: Ensure service account has required roles
3. **Quotas**: Check GCP quotas for Cloud Run/Functions

### Enable Required APIs
```bash
gcloud services enable storage.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```