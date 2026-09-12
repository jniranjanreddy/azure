
## This page is specific to Identities
# Azure (Microsoft Entra ID) Identity Types

Azure identities broadly split into two categories: **identities for people/devices** and **identities for applications/workloads**. Here's the full breakdown.

---

## 1. User Identity

A **user** is an identity representing a person, authenticated with a password, MFA, passwordless (FIDO2/Authenticator), etc.

**Subtypes:**
- **Cloud-only user** — created directly in Microsoft Entra ID (no on-prem AD).
- **Hybrid/synced user** — synced from on-prem Active Directory via Entra Connect (Azure AD Connect); password hash sync, pass-through auth, or federation (ADFS).
- **Guest user (B2B collaboration)** — external user (partner, vendor, contractor) invited into your tenant with their own credentials from their home tenant.

**3 use cases:**
1. **Employee login to Azure Portal/M365** — a full-time employee's cloud-only or hybrid-synced account used for daily SSO into Azure resources, Teams, SharePoint.
2. **External auditor access** — invite a security auditor as a **B2B guest** with time-boxed, read-only RBAC access to a subscription for a compliance review, then remove access after.
3. **Break-glass emergency admin account** — a cloud-only user account excluded from Conditional Access, with a very strong credential stored offline, used only if normal admin accounts/MFA are locked out.

---

## 2. Group Identity

A **group** bundles users (and sometimes devices/other groups) so permissions can be assigned once and inherited.

**Subtypes:**
- **Security group** (assigned or dynamic membership) — used purely for access control (RBAC, Conditional Access, app access).
- **Microsoft 365 group** — collaboration-focused (Teams, SharePoint, shared mailbox) but can also carry RBAC.
- **Dynamic group** — membership auto-computed from user/device attributes (e.g., `department -eq "Finance"`).

**3 use cases:**
1. **RBAC at scale** — assign `Contributor` on a resource group to a "Platform-Team" security group instead of 10 individual users; adding/removing a person from the group updates access automatically.
2. **Conditional Access targeting** — a dynamic group of all users with `jobTitle contains "Contractor"` gets a stricter Conditional Access policy (mandatory MFA + blocked from downloading files).
3. **License/app assignment** — a Microsoft 365 group auto-assigns a specific SaaS app or license to everyone in the "Sales" department dynamically.

---

## 3. Service Principal (the general "app identity" concept)

A **service principal (SP)** is the local representation of an application/service inside a specific tenant — it's what actually gets permissions, RBAC roles, and can authenticate. It's created from an **App Registration** (the global definition of the app).

Think of it as: **App Registration = the app's identity card (global, one per app, in its home tenant)**, **Service Principal = the app's access badge (local instance in each tenant where it's used)**.

**Subtypes:**
- **Application (App Registration–backed) service principal** — you register the app, get a Client ID + tenant ID, and authenticate using a **client secret** or **certificate**.
- **Managed Identity service principal** — Azure creates and manages the SP + credentials for you (see section 4 — no secrets to handle).
- **Legacy / third-party (multi-tenant) service principal** — an SP created in your tenant representing someone else's multi-tenant app (e.g., you consented to a SaaS product like Datadog or Snyk accessing your tenant).

**3 use cases:**
1. **CI/CD pipeline authentication** — Azure DevOps/GitHub Actions uses an app registration + service principal with a client secret/cert to run `az deployment` commands against a subscription.
2. **Third-party SaaS integration** — approving a monitoring tool (e.g., Datadog) creates a service principal in your tenant with delegated/application permissions to read metrics via Microsoft Graph or Azure APIs.
3. **Custom application backend auth** — a line-of-business API registers an app so it can call Microsoft Graph (e.g., read user profile photos) using client-credentials flow.

---

## 4. Managed Identity (a special, secret-free Service Principal)

Purpose-built so Azure resources can authenticate **without you ever handling a credential** — Azure rotates it internally.

**Subtypes:**
- **System-assigned managed identity** — lifecycle tied 1:1 to the resource (e.g., a VM or AKS cluster); deleted automatically when the resource is deleted.
- **User-assigned managed identity** — a standalone Azure resource that can be attached to multiple resources, with an independent lifecycle.
- *(Workload identity federation, a related mechanism, is covered in section 6.)*

**3 use cases:**
1. **VM pulling secrets from Key Vault** — a VM with a **system-assigned** managed identity is granted `Key Vault Secrets User` so its app can fetch a DB connection string with zero stored credentials.
2. **AKS pods accessing Azure resources** — an AKS cluster uses a **user-assigned** managed identity (kubelet identity) to pull images from Azure Container Registry or manage load balancers.
3. **Shared identity across multiple Function Apps** — a **user-assigned** managed identity is attached to five different Azure Functions so they all share one identity with `Storage Blob Data Contributor` rights, simplifying access review to one principal instead of five.

---

## 5. Device Identity

Represents a physical/virtual device registered in Entra ID, used mainly for Conditional Access ("require compliant device") and device management.

**Subtypes:**
- **Entra registered** — personal/BYOD device, lightweight registration (e.g., personal phone with Authenticator app).
- **Entra joined** — cloud-native, fully managed device (no on-prem AD at all).
- **Entra hybrid joined** — device joined to both on-prem AD and Entra ID (common in enterprises mid-migration).

**3 use cases:**
1. **Conditional Access "compliant device required"** — block access to sensitive admin portals unless the sign-in comes from a device marked compliant by Intune.
2. **BYOD email access** — allow an employee's personal phone (Entra registered) to access Outlook mobile only within an Intune App Protection Policy (no full device management needed).
3. **Corporate laptop SSO** — Entra hybrid-joined laptops get seamless SSO to on-prem file shares and cloud apps simultaneously.

---

## 6. Workload Identity Federation (Federated Credentials)

Not a separate identity type per se, but a **credential mechanism** that lets an external workload (outside Azure) exchange its own OIDC token for an Azure token, tied to an App Registration or Managed Identity — **eliminating secrets entirely**, even for external systems.

**3 use cases:**
1. **GitHub Actions → Azure deployment** — a GitHub Actions workflow uses OIDC federation to an app registration's federated credential, authenticating to Azure with zero stored secrets in GitHub.
2. **Kubernetes workload identity (AKS)** — a pod's Kubernetes service account token is federated to a managed identity, letting the pod call Azure Storage/Key Vault without any mounted secret.
3. **Multi-cloud CI** — a GitLab CI pipeline running outside Azure federates its GitLab OIDC token to an Azure app registration to push artifacts to Azure Container Registry.

---

## 7. External Identities (customer-facing, distinct from workforce identities)

For scenarios where you're authenticating **your customers/partners**, not employees.

**Subtypes:**
- **B2B collaboration** (covered above under guest users) — for partners/vendors accessing your internal resources.
- **B2B direct connect** — mutual, seamless trust between two Entra tenants (e.g., Teams shared channels) without invite/redemption.
- **External ID / CIAM (customer identity)** — a separate tenant type for customer-facing apps, supporting social logins (Google, Facebook) and custom branding.

**3 use cases:**
1. **SaaS customer login portal** — a customer-facing web app uses Entra External ID (CIAM) so end customers sign up/log in with email or Google/Facebook accounts.
2. **Cross-company Teams collaboration** — two companies use B2B direct connect so employees see each other in shared Teams channels without a formal guest invite each time.
3. **Partner self-service portal** — external vendors log into a procurement portal via B2B guest invitation, scoped to only the specific SharePoint site/app they need.

---

## Quick Summary Table

| Identity type | Represents | Credential | Typical owner |
|---|---|---|---|
| User | Person | Password/MFA/passwordless | IT/HR |
| Group | Collection of users/devices | N/A (inherits) | IT admin |
| Service Principal (app-based) | Application/service | Client secret/certificate | App/DevOps team |
| Managed Identity | Azure resource | Auto-rotated, no secret | Azure-managed |
| Device | Physical/virtual device | Device certificate | IT/Intune |
| Federated credential | External workload | OIDC token exchange | DevOps/security |
| External Identity | Customer/partner | Varies (social, B2B) | Product/business team |
