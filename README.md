# 🛒 End-to-End GitOps Microservices Platform

A production-grade, automated platform for deploying an ecommerce microservice ecosystem on AWS. This project integrates **Infrastructure-as-Code (Terraform)**, **Continuous Integration (Jenkins)**, and **GitOps-driven Continuous Deployment (ArgoCD)**.



## 🏗️ Project Overview
The goal of this project is to simulate a real-world enterprise environment. It features a 4-service architecture (Auth, Order, Product, API-Gateway) running on a secure, private Kubernetes (K3s) cluster with a completely automated "Push-to-Deploy" workflow.

### **🛠️ The Tech Stack**
* **Cloud:** AWS (VPC, EC2, ALB, NAT Gateway)
* **IaC:** Terraform (Workspaces, Multi-AZ Networking)
* **CI:** Jenkins (Shared Libraries, Trivy Security, Controller-Agent Architecture)
* **CD:** ArgoCD (App-of-Apps Pattern, Drift Detection)
* **Orchestration:** K3s (Kubernetes)
* **Security:** Trivy (Vulnerability Scanning), Private Subnet Isolation

---

## 🛰️ System Architecture

Infrastructure is built for **High Availability** and **Security**:
* **Isolation:** All compute nodes (Jenkins & K3s) are locked in **Private Subnets**.
* **Traffic Flow:** External users hit an **Application Load Balancer (ALB)**, which routes traffic into the private cluster.
* **Security:** Outbound traffic for updates is handled via a **NAT Gateway**, ensuring no direct inbound access from the internet.

![System Architecture](<./terraform/diagram-export-1-14-2026-12_03_14-PM.png>)

---

## 🔄 The Automation Workflow

1.  **Code Push:** Developer pushes a change to the `master` branch.
2.  **Continuous Integration:** * Jenkins triggers a build on a dedicated **Agent node**.
    * **Trivy** scans the filesystem and the Docker image for vulnerabilities.
    * The verified image is pushed to **DockerHub**.
3.  **GitOps Trigger:** * Jenkins updates the Kubernetes manifests in the `/k8s` folder with the new image tag.
4.  **Continuous Deployment:** * **ArgoCD** detects the manifest change (GitOps).
    * ArgoCD performs a **Rolling Update** to the K3s cluster.
    * **Liveness/Readiness probes** ensure zero-downtime during the transition.

---

## 📂 Repository Structure

* [**`/terraform`**](./terraform/README.md): AWS Infrastructure logic (VPC, Subnets, EC2, Workspaces).
* [**`/jenkins`**](./jenkins/README.md): CI Pipeline logic and Shared Libraries.
* [**`/k8s`**](./k8s/README.md): Kubernetes manifests using Kustomize (Base/Overlays).
* [**`/argocd`**](./argocd/README.md): App-of-Apps deployment configuration.
* [**`/docs`**](./docs/): Detailed setup guides and installation tutorials.

---

## 🚀 Getting Started

To replicate this environment, please follow the documentation in order:

1.  **Infrastructure:** Set up the AWS environment via [Terraform](./terraform/README.md).
2.  **CI Setup:** Configure the [Jenkins](./jenkins/README.md) controller and agents.
3.  **CD Setup:** Install [ArgoCD](./argocd/README.md) and bootstrap the App-of-Apps.

---

## ✅ Key Achievements
* Implemented **Zero-Downtime** deployments via Kubernetes Rolling Updates.
* Achieved **"Infrastructure-as-Code"** with Terraform Workspaces for environment isolation.
* Secured the build pipeline with **Trivy** container scanning.
* Established a **Pull-based CD model** using ArgoCD to eliminate manual `kubectl` intervention.

---

## 📜 Credits & Attribution

This project is a customized implementation and enhancement of the microservices architecture originally developed by:

**Author:** [hmn53](https://github.com/hmn53)  
**Original Repository:** [ecommerce-microservice](https://github.com/hmn53/ecommerce-microservice)

*Modifications include the integration of Terraform Workspaces, a Multi-AZ AWS architecture, ArgoCD, Kubernetes setup and a Jenkins Controller-Agent setup with Trivy security integration.*