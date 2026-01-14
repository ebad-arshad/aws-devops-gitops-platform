# 📖 Jenkins CI Setup Tutorial

This guide walks you through the process of onboarding the microservice pipelines into your Jenkins environment.

## 🛠️ Prerequisites

Before starting the setup, ensure the following requirements are met:

1.  **Jenkins Infrastructure:** A running Jenkins Controller.
2.  **Agent Configuration:** A dedicated Linux node named `user` must be connected as an **Agent (Slave)** via SSH.
3.  **Credentials:**
    * `dockerhub-creds`: DockerHub username and password.
    * `github-creds`: GitHub Personal Access Token (PAT) for manifest updates.
4.  **Environment Sync:** Update the `environment {}` block in each service's `Jenkinsfile` to match your github repository names.

---

## 🚀 Step-by-Step Pipeline Configuration

### 1. Create the Pipeline Job
* Navigate to the Jenkins Dashboard and select **New Item**.
* Enter the name of your service (e.g., `auth-service`).
* Select **Pipeline** and click **OK**.

### 2. Configure Pipeline-as-Code (SCM)
Instead of writing the script manually in the UI, we link it directly to the repository:
* **Definition:** Select "Pipeline script from SCM".
* **SCM:** Select "Git".
* **Repository URL:** Your GitHub repo link.
* **Credentials:** Select your GitHub credentials.
* **Branch:** Ensure it matches your repo branch (e.g., `*/master`).
* **Script Path:** Enter the path to the specific service's Jenkinsfile (e.g., `auth/Jenkinsfile`).

![Jenkins Pipeline Configuration](<Screenshot from 2026-01-14 10-36-43.png>)
![Jenkins SCM Settings](<Screenshot from 2026-01-14 10-37-35.png>)

### 3. Repeat for All Microservices
Repeat the steps above for the remaining three services to ensure the entire ecommerce ecosystem is covered:
* `api-gateway`
* `order-service`
* `product-service`

### 4. Execute the Initial Build
Once all pipelines are created, navigate to each job and click **Build Now**. 

> **Note:** The pipeline will perform a **Sparse Checkout**. It only pulls the code for that specific service and the Kubernetes manifests, keeping the build agent efficient and clean.

---

## 💡 Note

* **Initial Run:** The first build might take longer as it pulls the required Docker images to the Agent node.
* **GitOps Sync:** If the build is successful, check your GitHub repo. You should see a new commit from Jenkins updating the image tag in the `/k8s` directory with the prefix `CI:`.
* **Security Check:** If a build fails during the **Trivy Scan**, check the console output. It means a "High" or "Critical" vulnerability was found in the code or the base image.