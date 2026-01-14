# 📖 ArgoCD Setup Tutorial

This guide provides the necessary steps to install ArgoCD and deploy the microservices using the App-of-Apps pattern.

## 📝 Introduction
This documentation covers the Continuous Deployment (CD) phase of the project. By using ArgoCD, we ensure that the Kubernetes cluster state is automatically synchronized with the configurations stored in this repository.

## 🛠️ Prerequisites
1. **Kubernetes Cluster:** Ensure your cluster is fully functional and accessible via `kubectl`.
2. **Namespace & Installation:** Run the following commands to set up the ArgoCD operator:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

# 🚀 Installation Steps

1. **Verify Pod Status:** Wait until all ArgoCD components are running successfully:
   ```bash
   kubectl get pods -n argocd
2. **Access the Dashboard:** Use port-forwarding to expose the ArgoCD API server to your local machine:
   ```bash
   kubectl port-forward service/argocd-server -n argocd 8081:443
3. **Open Browser:** Navigate to: **http://localhost:8081**
4. **Login Credentials:** 
   **Username:** admin
   **Password:** Retrieve your unique initial password by running:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
5. **Deploy Project & App-of-Apps:** Navigate to the argocd/ directory in your terminal and apply the following manifests:
   ```bash
   kubectl apply -f project.yaml -f app-of-apps.yaml
5. **Monitor Synchronization:** Head over to the Applications tab in the UI: **http://localhost:8081/applications**
6. **Verification:** You will observe the applications being created automatically. After a few moments, all services will reach a "Healthy" and "Synced" status.
![working argoCD applicaions](<Screenshot from 2026-01-14 11-25-26.png>)

# 🎯 Conclusion
ArgoCD is now successfully managing the application lifecycle. Any changes made to the Kubernetes manifests in the repository will be detected and applied to the cluster automatically, maintaining the GitOps "Source of Truth."