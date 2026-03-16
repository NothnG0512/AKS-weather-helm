**High-Availability Weather Platform on Azure (AKS)**
A Full-Stack DevSecOps Implementation using GitOps, IaC, and Cloud-Native Security

This repository contains the end-to-end engineering of a containerized Weather API. The project demonstrates a production-ready infrastructure lifecycle—from automated provisioning with Terraform to continuous delivery with ArgoCD, secured via Azure Key Vault and monitored through Managed Prometheus/Grafana.


🏗️ **System Architecture**
The platform is built on a modular, scalable architecture designed for resilience and security:

**Orchestration:** Azure Kubernetes Service (**AKS**) with Managed Node Pools.

**Infrastructure as Code**: Modular Terraform (HCL) managing VNETs, ACR, AKS, and Key Vault.

**Continuous Delivery:** GitOps workflow using ArgoCD to maintain a "Zero Drift" state.

**Identity & Security**: Azure Workload Identity for pod-level permissioning and Secret Store CSI for secure credential mounting.

**Observability:** Integrated Prometheus metrics and Grafana dashboards for cluster-wide visibility.


**🛠️ Core Engineering Highlights**
**1. The GitOps Workflow (The "Push-to-Live" Engine)**
I implemented a declarative CD pipeline that ensures the cluster state always matches the Git repository.

**CI:** GitHub Actions builds Docker images, tags them with the commit SHA, and pushes to Azure Container Registry.

**CD:** A custom automation script updates the Helm values in the GitOps repo, triggering ArgoCD to pull the new state into the cluster.

**Self-Healing:** If manual changes are made via kubectl, ArgoCD automatically reverts the cluster to the "Source of Truth" in Git.

**2. Zero-Trust Secret Management**
To eliminate the risk of hardcoded secrets, I transitioned from native Kubernetes Secrets to an integrated Vault solution:

Technology: Azure Key Vault + Secrets Store CSI Driver.

Implementation: Secrets are mounted as ephemeral volumes. I configured RBAC and Workload Identity to ensure that only authorized pods can access specific secret keys, following the principle of Least Privilege.

**3. Resilience & Chaos Engineering**
The platform was stress-tested to ensure high availability:

Probes: Implemented Liveness and Readiness probes to ensure zero-downtime rolling updates.

Disaster Recovery: The entire environment can be destroyed and re-provisioned from a blank Azure account in <30 minutes using the Terraform state and ArgoCD application manifests.


**📈 Observability & Monitoring**
The cluster is monitored using Azure Managed Prometheus.

**Dashboards:** Custom Grafana dashboards track Pod CPU/Memory, Ingress traffic, and Request Latency.

**Alerting:** Configured for high-latency and pod-restart loops to ensure proactive incident management.




**🚀 How to Replicate**
Provision Infra: cd terraform && terraform apply

Bootstrap GitOps: Apply the ArgoCD bootstrap manifest in /gitops-config.

Deploy: Push a code change to /src, and watch the automated rollout.



**🛠️ Challenges Overcome**
**1. Solving the "Ghost Ingress" & Resource Drift**
**The Problem**: After transitioning to ArgoCD, the cluster was stuck in a "Progressing" state due to a legacy Ingress resource that lacked a valid LoadBalancer IP. This "Ghost" resource prevented the application from ever reaching a "Healthy" status.

**The Solution:** Leveraged ArgoCD’s Pruning and Self-Healing capabilities. I audited the Helm templates to remove the unused Ingress manifest and synchronized the state.

**Engineering Takeaway:** Deepened understanding of the Kubernetes reconciliation loop and the importance of ensuring the "Desired State" in Git is clean and achievable by the "Live State."

**2. The Identity & Access Management (IAM) "Fight"**
The Problem: While implementing the Secret Store CSI Driver, pods remained in ContainerCreating with PermissionDenied errors. The challenge was identifying which specific identity (Add-on Identity vs. Workload Identity) required the RBAC roles.

**The Solution:** Used kubectl describe to trace the failure to the CSI driver's mount process. I resolved the bottleneck by mapping the Managed Identity of the AKS Secret Provider to the Key Vault Secrets User role via Azure RBAC at the resource scope.

Engineering Takeaway: Mastered the "Least Privilege" principle by moving away from global Access Policies to granular, scope-based RBAC role assignments.

**3. GitOps Automation Loop (Race Conditions)**
**The Problem:** Initially, the GitHub Actions CI pipeline and the ArgoCD sync process created a potential infinite trigger loop when updating the image tags in the manifest repository.

**The Solution:** Implemented logic within GitHub Actions to use [skip ci] in commit messages for automated tag updates and configured ArgoCD with a specific sync policy to handle the "Image Updater" pattern efficiently.

Engineering Takeaway: Gained expertise in designing CI/CD workflows that are "Loop-Aware" and decoupled, ensuring stable and predictable deployments.



Anuj Pal 
**DevOps & Infrastructure Engineer**
