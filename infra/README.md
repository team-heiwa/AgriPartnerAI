# Infrastructure Configuration

This directory contains Terraform configurations for provisioning GCP resources required by the AgriPartner AI pipeline.

## Prerequisites

1. Google Cloud SDK installed
2. Terraform >= 1.5.0
3. GCP Project with billing enabled
4. Appropriate IAM permissions

## Setup

1. **Initialize GCP Authentication**
   ```bash
   gcloud auth application-default login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Create Terraform State Bucket**
   ```bash
   gsutil mb gs://agripartner-terraform-state
   gsutil versioning set on gs://agripartner-terraform-state
   ```

3. **Configure Terraform Variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan and Apply**
   ```bash
   terraform plan
   terraform apply
   ```

## Resources Created

- **Cloud Storage Buckets**
  - Input bucket: For uploading media files
  - Output bucket: For storing processed results
  - Temp bucket: For intermediate processing

- **IAM**
  - Service Account: `pipeline-processor-{env}`
  - Roles: Storage access, Vertex AI access, Logging

- **APIs Enabled**
  - Cloud Storage API
  - Vertex AI API
  - IAM API
  - Cloud Resource Manager API
  - Cloud Logging API

## Outputs

After applying, Terraform will output:
- Bucket names
- Service account email
- Service account key (base64 encoded)

## Service Account Key

To use the service account locally:

```bash
# Get the key from Terraform output
terraform output -raw service_account_key | base64 -d > service-account-key.json

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/service-account-key.json"
```

⚠️ **Security Note**: Never commit service account keys to version control!