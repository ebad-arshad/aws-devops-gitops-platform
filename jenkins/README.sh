# 🛠️ Microservice CI with Jenkins

This directory contains the pipeline logic for 4 independent microservices. The architecture is built to be modular, secure, and optimized for a GitOps workflow.

## 🌟 Key Features

* **Jenkins Shared Libraries:** I use a Shared Library to centralize common pipeline logic, significantly reducing code duplication across the 4 microservices.
* **Controller-Agent Architecture:** All build workloads are executed on a **dedicated Linux Agent (Slave node)** rather than the Jenkins Controller. 
* **Semantic Versioning:** The pipeline automatically manages environment variables to tag images in a standardized `x.x.x` format.

---

## 🏗️ Pipeline Stages

### 1. **Preparation**
* **Cleaning Workspace:** Ensures a fresh start by removing any artifacts from previous builds.
* **Sparse Checkout:** A performance-optimized clone that pulls only the `/app` and `/k8s` directories.
    * `/app`: Used for security scanning and Docker image creation.
    * `/k8s`: Used to update the deployment manifests that ArgoCD monitors.

### 2. **GitOps Intelligence**
* **Check Changes:** The pipeline inspects the commit message. If it detects a commit starting with `CI:`, it recognizes this as an automated GitOps update and skips the pipeline to prevent an infinite build loop.

### 3. **Security Analysis**
* **Trivy FS Scan:** I perform a static analysis of the source code filesystem to identify high and critical vulnerabilities before the build proceeds.

### 4. **Image Lifecycle**
* **DockerHub Integration:** Secure authentication using Jenkins Credentials.
* **Build, Scan & Push:** The image is built, scanned for vulnerabilities, and pushed to DockerHub with a unique version tag.

### 5. **GitOps Manifest Update**
* **Automated Sync:** The pipeline logs into GitHub, updates the image version in the Kubernetes manifests (`/k8s` folder), and commits the change with the message: `CI: Updated Image`.

---

## 📖 Detailed Setup & Tutorials
For a full walkthrough on setting up Jenkins and managing credentials, please refer to the documentation in the root `docs` folder:

👉 [Jenkins Setup Tutorial](../docs/jenkins-setup.md)