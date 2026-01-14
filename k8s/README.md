K8s for microservices

intro read the info below first to write the intro here

features
kustomization
base/ and overlays/ directories for environment seperation
api-gateway auth product order services have deployment service and kustomization
api-gateway-db auth-db product-db order-db services have statefulset service and kustomization
rabbitmq have statefulset service and kustomization
secrets are mananged in overlays by secretGenerator
argocd running this code

add points/things you want to add

pods are following rolling update 
revisionHistoryLimit: 2
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
      liveness readiness probes
      resource req limit
      replicas 
outro








# ☸️ Kubernetes Orchestration (Kustomize)

This directory houses the Kubernetes manifests for the ecommerce microservices ecosystem. We utilize **Kustomize** to implement a robust "Base and Overlay" strategy, enabling environment-specific configurations while maintaining a DRY (Don't Repeat Yourself) codebase.

## 📝 Introduction
The architecture is designed for high availability and automated GitOps delivery. By separating core resource definitions (`base/`) from environment tweaks (`overlays/`), we allow **ArgoCD** to apply precise patches for Development and Production environments without modifying the primary template.

---

## 🚀 Key Architectural Features

### 1. Kustomize Structure
* **`base/`**: Defines the fundamental building blocks (Deployments, StatefulSets, Services) for every microservice and database.
* **`overlays/`**: Contains environment-specific logic (`dev`, `prod`). 
* **`secretGenerator`**: Secrets are managed within the overlays, ensuring sensitive credentials are never hardcoded and are refreshed per environment.

### 2. Microservice Deployment Strategy
All services are configured with production-grade stability patterns:
* **Stateless App Pods:** `api-gateway`, `auth`, `product`, and `order` use **Deployments**.
* **Stateful Components:** Databases (`auth-db`, `order-db`, `product-db`) and **RabbitMQ** use **StatefulSets** to ensure stable networking and persistent data storage.

### 3. High Availability & Self-Healing
To ensure 99.9% uptime, the following pod disruption and health policies are enforced:
* **Rolling Update Strategy:**
    * Adds one pod at a time during updates to handle traffic.
    * Ensures no downtime by keeping all required replicas running during a rollout.
* **Health Checks:** Integrated **Liveness** and **Readiness** probes ensure traffic only hits healthy pods and automatically restarts failing ones.
* **Resource Governance:** Strict **CPU/Memory requests and limits** are applied to prevent resource contention.
* **Revision Management:** is set to allow quick rollbacks while keeping the cluster clean.

---

## 📁 Directory Structure

```text
k8s/
├── base/                     
│   ├── api-gateway/           
│   ├── auth/
│   ├── order/
│   ├── product/
│   ├── postgres/              
│   └── rabbitmq/              
└── overlays/                  
    ├── dev/                   
    │   ├── base/              
    │   └── db/                
    └── prod/                  
        ├── base/
        └── db/