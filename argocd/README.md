# 🎡 Continuous Deployment with ArgoCD (GitOps)

This directory contains the GitOps configuration for the ecommerce platform. By using ArgoCD, we ensure that the state of our Kubernetes cluster always matches the desired state defined in our Git repository.

## 🌟 Why ArgoCD instead of Jenkins for CD?

While Jenkins is an excellent tool for **Continuous Integration (CI)**, we chose ArgoCD for **Continuous Deployment (CD)** for the following reasons:

* **The Pull Model:** Unlike Jenkins, which "pushes" changes (requiring complex firewall rules and credentials to be stored outside the cluster), ArgoCD lives inside the cluster and "pulls" updates. This is more secure and Kubernetes-native.
* **Overcoming Connectivity Barriers:** Kubernetes does not by default allow external services like Jenkins to communicate with the API server easily. ArgoCD bypasses this by operating internally.
* **Visual Insight:** ArgoCD provides a real-time visual representation of all Kubernetes resources, making it easier to debug deployment issues.

---

## 🛠️ Key Architectural Features

### 1. **App-of-Apps Pattern**
We utilize the **App-of-Apps** pattern. A single "Root" application is created in ArgoCD, which then manages and deploys all individual microservices located in the `applications/` directory. This allows for a single point of management for the entire ecosystem.

### 2. **Automated Drift Detection**
ArgoCD constantly monitors the cluster. If a developer manually changes a setting in the cluster (e.g., via `kubectl edit`), ArgoCD will immediately flag the resource as `OutOfSync`.

### 3. **Self-Healing & Auto-Sync**
When a drift is detected or a new image tag is pushed by Jenkins to the `k8s/` folder, ArgoCD automatically triggers a synchronization to bring the cluster back to the desired state defined in Git.

### 4. **Revision History**
The system is configured to store the **last 2 revisions**. This ensures that if a new deployment causes issues, we can perform an instant rollback to a known stable version with a single click.

---



## 🚀 Deployment Workflow

1. **CI Completion:** Jenkins pushes a new image tag to the `k8s/` manifests.
2. **Detection:** ArgoCD detects the commit in the Git repository.
3. **Sync:** ArgoCD pulls the new manifests and applies them to the cluster.
4. **Validation:** ArgoCD monitors the rollout until all pods are in a `Healthy` state.

---

## 📖 Setup & Tutorial
For a detailed guide on installing the ArgoCD operator, configuring the Root Application, and setting up repository secrets, please refer to the documentation in the root `docs` folder:

👉 [ArgoCD Setup Tutorial](../docs/argocd/README.md)