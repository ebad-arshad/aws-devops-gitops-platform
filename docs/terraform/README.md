## 🚀 Deployment Guide

### **Prerequisites**
- AWS CLI installed and configured.
- Terraform CLI (v1.x+).
- Terraform configured with AWS through Access key
- An SSH Key Pair named terraform created in the `ap-south-1` region.
- Create a S3 bucket and use that name instead of ebad-arshad-s3-bucket-ecommerce-tfstate in terraform.tf
- Create DynamoDB, set name to terraform-lock and partition key to LockID

### **Quick Start**
0. ### **Workspace Commands**
```bash
# List available workspaces
terraform workspace list

# Create and switch to dev workspace
terraform workspace new dev
```
---
1. **Initialize Terraform:**
   ```bash
   terraform init
2. **Review Infrastructure Plan:**
   ```bash
   terraform plan
3. **Apply Configuration:**
   ```bash
   terraform apply -auto-approve

## Note

**Once you are done with trying this out make sure to run the command below to destroy the infrastructure otherwise AWS will keep charging you for the services**
   ```bash
   terraform destroy -auto-approve