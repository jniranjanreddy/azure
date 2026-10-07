## Azure Firewall deployment
```
part1- https://www.youtube.com/watch?v=5VtUwK3hRTM
part-2 - https://www.youtube.com/watch?v=vHdb_VRZFIs
```
## Rules
```

DNAT Rule        - Destination Network Address Translation.
Network Rule     -
Application Rule - 


```
## DNAt Rules
```
<img width="494" height="356" alt="image" src="https://github.com/user-attachments/assets/fd50c1fb-ed1f-4401-8aa9-c57440bfb439" />

```
## Network Rules
```
<img width="483" height="335" alt="image" src="https://github.com/user-attachments/assets/46e7156f-9ed9-47d0-a1e9-044ae8256b96" />

```
## Application rules
```
<img width="515" height="350" alt="image" src="https://github.com/user-attachments/assets/2418203a-f2cc-46eb-9f6d-d0e110dc292b" />

```
# Azure Application Gateway + Azure Firewall: the nuts and bolts

A working reference for understanding, designing, building, and debugging
**Azure Application Gateway (with WAF)** and **Azure Firewall**, individually and
together.

## How to use this document

1. Read **Part 1** once, to get the mental model of where each service sits.
2. Work through **Part 2 (Application Gateway)** and **Part 3 (Azure Firewall)**.
3. Read **Part 4** for the designs that combine them. This is where most real
   mistakes happen.
4. Do the labs in **Part 7**. Reading alone won't make you fluent in these.
5. Keep **Part 6** open while troubleshooting.

### Verification status (read this)

Facts below were checked against Microsoft Learn on **2026-10-03**. Page
"last updated" dates were between 2026-03 and 2026-09. These areas are verified
and marked **(verified)** where it matters:

- App Gateway v2 subnet sizing, NSG and UDR rules, SKU/limits table, v1 retirement
- WAF anomaly scoring, modes, rule processing, policy scopes
- Azure Firewall SKU comparison, rule-processing order, SNAT/DNAT behavior,
  subnet size, timeouts, scaling thresholds, forced tunneling
- Combined Firewall + App Gateway architectures

Anything marked **(confirm)** is standard knowledge or recalled defaults that I
could not re-check against a doc. Confirm those in the portal or with `--help`
before depending on exact values. Azure CLI flags in particular change between
versions, so run `az <command> --help` before copying commands into automation.

Limits, SKUs, and rule-set versions change often. Treat the **References**
section at the bottom as the source of truth over this file.

---

# Part 1: The mental model

## 1.1 What each service is for

| Service | OSI layer | Direction it's best at | Core job |
|---|---|---|---|
| **Application Gateway** | L7 (HTTP/HTTPS/HTTP2/WebSocket; also L4 TCP/TLS proxy on v2) | Inbound | Regional reverse proxy and load balancer for web apps: TLS termination, host/path routing, WAF |
| **Azure Firewall** | L3-L7 | Outbound and east-west (also inbound for non-HTTP) | Centralized, stateful network firewall: FQDN filtering, DNAT/SNAT, threat intel, IDPS (Premium) |
| **NSG** | L3-L4 | Both (distributed) | Cheap, distributed allow/deny on subnet/NIC. No FQDNs, no L7 |
| **Azure Front Door** | L7 | Inbound, global | Global edge entry point, CDN, global WAF |
| **Load Balancer** | L4 | Inbound/internal | Non-HTTP L4 load balancing |
| **Traffic Manager** | DNS | Inbound, global | DNS-based routing across regions |

The official one-liner for the App Gateway WAF vs Firewall question
**(verified)**: Application Gateway WAF is *centralized inbound protection for web
applications*. Azure Firewall provides *inbound protection for non-HTTP/S
protocols (RDP, SSH, FTP), outbound network-level protection for all ports and
protocols, and application-level protection for outbound HTTP/S*. They are
complementary, not substitutes.

## 1.2 Which one do I reach for?

```
Is the traffic HTTP(S) coming from the internet to my web app?
  yes -> Application Gateway (WAF_v2)   [regional]   or Front Door [global]
  no  -> Is it inbound non-web traffic (RDP/SSH/custom TCP)?
           yes -> Azure Firewall DNAT (or a Load Balancer + NSG)

Do I need to control/inspect OUTBOUND traffic (egress, exfiltration, FQDN allow-lists)?
  yes -> Azure Firewall (NSGs can't do FQDNs)

Do I need east-west segmentation between subnets within one VNet?
  -> NSGs first (cheap, no UDRs). Firewall only if you need L7/FQDN/IDPS between them.
```

## 1.3 The two rules that explain most outages

1. **Application Gateway v2 must have a direct path to the internet for its
   control plane.** You cannot send `0.0.0.0/0` from the App Gateway subnet to a
   firewall/NVA **(verified)**.
2. **Azure Firewall must see both directions of a flow.** Return traffic that
   hits a different firewall instance (or bypasses it) breaks the session. This
   is *asymmetric routing*, the number-one firewall design bug.

Keep those two in your head and Part 4 will make sense immediately.

---

# Part 2: Azure Application Gateway

## 2.1 SKUs and versions (verified)

| SKU | Status | Notes |
|---|---|---|
| **v1** (Standard, WAF) | **Retired April 28, 2026. Unsupported.** | If you still have one, migrate to v2 now. |
| **Basic** (v2 family) | **Preview** | For low-traffic apps. SLA 99.9. Limited: no AKS/AGIC, no mTLS, no Private Link, no TCP/TLS proxy, no private-only, no URL rewrite. Needs preview feature registration. |
| **Standard_v2** | GA | Production. Autoscaling, zone redundancy, static VIP, header rewrite, Key Vault, mTLS, Private Link, AGIC, TCP/TLS proxy. SLA 99.95. |
| **WAF_v2** | GA | Standard_v2 plus Web Application Firewall. WAF *policy* associations are supported only on WAF_v2. |

v2-only capabilities worth knowing: autoscaling, zone redundancy (instances
spread across at least two zones by default), static VIP, header rewrite, Key
Vault integration, mTLS, Private Link, AKS ingress (AGIC), WAF custom rules,
WAF policy associations, enhanced network control (NSG, route table, private
frontend only), and TCP/TLS proxy.

v2 differences and limitations to remember **(verified)**:

- **FIPS mode:** not supported.
- **Path decoding:** v2 decodes paths *before* routing, so `/abc%2Fdef` is treated
  as `/abc/def`.
- **Chunked transfer with WAF_v2:** you can't disable request buffering on WAF_v2
  because the WAF must inspect the whole request. Workaround: create a path rule
  for the affected URL and attach a *disabled* WAF policy to that path rule.
- **Cookie affinity:** v2 can't append a domain to the session-affinity
  `Set-Cookie`, so subdomains can't share the cookie.
- **Mixing:** v1 and v2 can't share a subnet.

### Kubernetes: two products, don't confuse them

- **AGIC** (Application Gateway Ingress Controller): runs in the cluster and
  programs a v2 App Gateway from Ingress resources.
- **Application Gateway for Containers**: a separate Azure-managed L7 service for
  AKS, driven by the Kubernetes **Gateway API** and Ingress through an in-cluster
  controller. Microsoft points AKS users to this one in current guidance.

## 2.2 How a request flows

```
Client
  |  (1) DNS -> frontend IP (public and/or private)
  v
[ Frontend IP ] -> [ Listener ] -> [ Routing rule ] -> [ Backend settings ] -> [ Backend pool ]
   :80/:443         protocol,        basic or           protocol, port,         VMs / VMSS /
                    port, host,      path-based,        timeout, affinity,      App Service /
                    TLS cert         priority           probe, host header      FQDN / IPs
                                          |
                                          +-> (optional) rewrite rule set, redirect
  WAF policy attaches at gateway, listener, or path-rule level and inspects the
  request BEFORE it is forwarded.
```

Key behavior: the gateway **terminates** the client connection and opens a
**new** connection to the backend. The backend sees the *gateway instance's
private IP* as the source. The original client IP is added in the
`X-Forwarded-For` header **(verified)**. Your app and logs must read that header
if they need the real client IP.

## 2.3 Components, and how they connect

| Component | What it is | Gotchas |
|---|---|---|
| **Frontend IP config** | Public and/or private IP clients hit | v2 public IP must be **Standard SKU, Static**. Public + private listeners on the same port change the NSG destination (see 2.9) |
| **Listener** | Port + protocol + (optional) host name + cert | **Basic** = one site per port. **Multi-site** = host-header based, supports wildcards |
| **Routing rule** | Binds a listener to a backend target | v2 requires a unique **priority**. Lower number = evaluated first |
| **Backend pool** | The targets (IPs, FQDNs, VM NICs, VMSS, App Service) | Pool FQDNs resolve via the VNet's DNS |
| **Backend settings** | How to talk to the pool: protocol, port, timeout, affinity, probe, host-name override | Most 502s are born here |
| **Health probe** | Custom check of backend health | Default probe applies if you don't define one |
| **Rewrite rule set** | Edit headers/URL on request and response | Use for `X-Forwarded-*`, security headers, URL rewrites |
| **Redirect config** | HTTP to HTTPS, or to another listener/URL | Attach to a rule instead of a backend pool |
| **TLS/SSL policy** | Min protocol version and cipher suites | Choose a predefined policy; require TLS 1.2+ (confirm current default) |
| **WAF policy** | Managed + custom rules, exclusions, mode | One policy can be shared across gateways |

## 2.4 Listeners and routing

- **Basic listener:** accepts all traffic on a port, for one site.
- **Multi-site listener:** routes on the `Host` header, so you can host many sites
  on one gateway and one IP. Wildcard host names are supported.
- **Basic rule:** listener maps to one backend pool + one backend setting.
- **Path-based rule:** a *URL path map* sends `/api/*` to pool A, `/img/*` to pool
  B, and everything else to a default pool. Path rules are evaluated in listed
  order. Put the most specific paths first.
- **Redirect rule:** a typical pair is an HTTP listener (:80) with a redirect to the
  HTTPS listener (:443).
- **Priority:** every v2 rule needs a unique priority. Leave gaps (100, 200, 300)
  so you can insert rules later.

## 2.5 Backend settings and health probes (where 502s come from)

**Backend settings:**

| Setting | Why it matters |
|---|---|
| Protocol and port | HTTP or HTTPS to the backend. HTTPS enables end-to-end TLS |
| Request timeout | Default 20 seconds (confirm). Slow backends return 504/502 if this is too low |
| Cookie-based affinity | Sticky sessions via an `ApplicationGatewayAffinity` cookie (confirm cookie name). Breaks even load distribution |
| Connection draining | Lets in-flight requests finish when a backend is removed |
| Host header override | Either "pick from backend address" or a fixed host. **Critical for App Service / multi-tenant backends** that route on Host |
| Trusted root cert | Needed for HTTPS backends signed by a private CA |

**Health probes:**

- If you don't define a probe, a **default probe** is used. It hits the backend on
  the backend-settings port, with the host and protocol from those settings.
- A **custom probe** lets you set host, path (for example `/health`), interval,
  timeout, unhealthy threshold, and the expected response codes. Typical recalled
  defaults (confirm): interval 30s, timeout 30s, unhealthy threshold 3, healthy
  status codes 200-399.
- **The classic trap:** the probe's `Host` header doesn't match what the backend
  expects, so it returns a 404/301 and is marked unhealthy. Use "pick host name
  from backend settings" or set the probe host explicitly.
- If *all* backends are unhealthy, the gateway returns **502**.

```bash
# See exactly why a backend is unhealthy:
az network application-gateway show-backend-health -g <rg> -n <agw>
```

## 2.6 TLS and certificates

- **TLS termination (offload):** the gateway decrypts, then talks HTTP to the
  backend. Simplest and fastest, but traffic is plaintext inside the VNet.
- **End-to-end TLS:** the gateway decrypts (so the WAF can inspect), then
  **re-encrypts** to the backend. Backend settings use HTTPS. If the backend cert
  isn't from a public CA, upload the trusted root.
- **Certificates:** upload PFX directly, or (recommended) reference **Azure Key
  Vault** via a user-assigned managed identity. The gateway polls Key Vault for
  new cert versions, so renewals don't need manual re-upload (polling interval:
  confirm, commonly stated as 4 hours).
- **TLS policy:** pick a predefined policy with a TLS 1.2+ minimum. Use a custom
  policy only if you need specific ciphers.
- **mTLS (client certificate auth):** supported on Standard_v2 / WAF_v2
  **(verified)**, not Basic.
- **SNI:** multi-site HTTPS listeners can each have their own certificate.

## 2.7 Rewrites, redirects, and sessions

- **Header rewrite (v2)** can add, remove, or change request and response
  headers. It also supports URL rewrite. Use server variables (such as client IP
  and original host) to build values. Typical uses: add security headers
  (`Strict-Transport-Security`), strip `Server`, pass `X-Original-Host`.
- **Redirects** are cheaper than rewrites for HTTP-to-HTTPS.
- **Custom error pages** for 403 (WAF block) and 502 are supported.
- **WebSockets and HTTP/2:** supported. HTTP/2 is client-to-gateway. The gateway
  talks HTTP/1.1 to backends.

## 2.8 Scaling, capacity, and limits

**Autoscaling vs fixed capacity (v2):** you can run autoscaling (min/max
instances) or fixed capacity. Pricing is **consumption-based** (a fixed
component plus *capacity units*), not tied to instance size.

**Capacity unit (CU)** **(verified)**, per Standard_v2: 1 CU = up to **50**
connections/sec (RSA 2048-bit cert), **2.22 Mbps** throughput, **2,500**
persistent connections. Max **125 instances** per gateway.

**Per-SKU limits table (verified):**

| | Basic (preview) | Standard_v2 / WAF_v2 |
|---|---|---|
| SLA | 99.9% | 99.95% |
| Max connections/sec (RSA 2048) | 200 | 62,500 |
| Listeners | 5 | 100 |
| Backend pools | 5 | 100 |
| Backend servers per pool | 5 | 1,200 |
| Rules | 5 | 400 |
| Connections/sec per compute unit | 10 | 50 |

One gateway can host up to **40 websites that use WAF** **(verified, per the WAF
overview)**.

Autoscale tip: set **min capacity above 0** (commonly 2) for production. Scale-out
isn't instantaneous, and min 0 means cold starts under a sudden spike.

## 2.9 Networking requirements (verified, these cause real outages)

**Subnet**

- A **dedicated subnet** for App Gateway. You can't put any other resource in it.
- **v2: /24 recommended**, because the 125-instance maximum plus 5 Azure-reserved
  IPs plus the optional private frontend needs room, and autoscale and maintenance
  upgrades need headroom. (A /26 is the *v1* recommendation.)
- Each instance uses one private IP. A private frontend uses one more. Azure
  reserves 5 per subnet.
- Don't mix v1 and v2 in one subnet. `GatewaySubnet` is reserved for VPN gateways.
- Service endpoint *policies* aren't supported on the App Gateway subnet.

**NSG on the App Gateway subnet** (standard, non-private deployment)

| Direction | Rule | Source -> Destination : Port |
|---|---|---|
| Inbound | Client traffic | clients -> subnet prefix : your listener ports |
| Inbound | Infrastructure | `GatewayManager` -> Any : **65200-65535** (v2) |
| Inbound | Load balancer probes | `AzureLoadBalancer` -> Any : Any |
| Outbound | Internet | Any -> `Internet` : Any (**don't deny**) |

- If you have **public and private listeners on the same port**, the NSG
  destination for *all* inbound flows becomes the gateway's frontend IPs. Include
  both frontend IPs in the destination, or the rule won't match.
- The `GatewayManager` ports are protected by Azure certificates. Opening them
  doesn't expose management to the world.
- Don't override the default `AzureLoadBalancer` allow or the default internet
  outbound allow with a Deny.

**UDRs on the App Gateway subnet (v2)**

| Scenario | Supported |
|---|---|
| Disable BGP route propagation (route table) | Yes |
| `0.0.0.0/0` -> Internet | Yes |
| AKS kubenet pod-routing UDRs | Yes |
| **`0.0.0.0/0` -> firewall / NVA / hub / on-prem (forced tunneling)** | **No** |

Microsoft's guidance is blunt: UDRs on this subnet can make **backend health show
"Unknown"** and break logs and metrics. Avoid them unless required. Specific
prefix routes to a firewall (not `0.0.0.0/0`) are the pattern used in the
"App Gateway in front of Firewall" design (Part 4).

**Private-only deployments (Network Isolation):** relaxes the NSG and route-table
limits above. Read the "Private Application Gateway deployment" doc before using
it. The rules differ.

**Other**

- **DNS:** gateway instances honor the VNet's DNS setting. After changing it you
  must **stop and start** the gateway. Custom DNS must still resolve public
  internet names.
- **Permissions:** the identity deploying it needs
  `Microsoft.Network/virtualNetworks/subnets/join/action` and `.../read` on the
  subnet (Network Contributor has these).
- **Private Link:** v2 supports private endpoints to the gateway (not Basic).

## 2.10 WAF on Application Gateway

### Policy model **(verified)**

All WAF settings live in a **WAF policy** (managed rule sets, custom rules,
exclusions, file-upload limit, mode). A policy can attach at three scopes:
**gateway (global)**, **per-listener (per-site)**, or **per-URI (path rule)**.
That lets one gateway apply different rules to different apps. Policy
associations are WAF_v2 only.

### Rule evaluation order

1. **Custom rules** are evaluated first, in priority order (lower number = first).
   Actions: `Allow`, `Block`, `Log`.
2. Then **managed rule sets**. Once a rule matches and applies its action, lower-
   priority rules are not processed.

### Managed rule sets

- **OWASP Core Rule Set (CRS)** and Microsoft's **Default Rule Set (DRS)**.
  The WAF overview lists **CRS 3.2, 3.1, 3.0** as supported. CRS **3.2 or later
  runs on the newer, faster WAF engine**; older CRS versions run on the old
  engine and don't get new features. Check the DRS/CRS rule-groups page for which
  version is current and which are deprecated.
- **Bot Manager rule set:** categorizes bad / good / unknown bots. Defaults:
  blocks malicious, allows verified search engines, blocks unknown search engine
  crawlers, logs unknown bots. `Allow` action applies only to the bot rule set,
  not CRS.
- **IP Reputation** rule set for malicious-bot protection.

### Anomaly scoring (verified, key to tuning)

CRS 3.x doesn't block on a single match. Each match adds to an **anomaly score**,
and the request is blocked if the total reaches the **threshold of 5** (in
Prevention mode):

| Severity | Score |
|---|---|
| Critical | 5 |
| Error | 4 |
| Warning | 3 |
| Notice | 2 |

So one **Critical** match alone blocks. One **Warning** (3) does not, but a
Warning + Notice (5) does. In logs, individual rule hits show action `Matched`.
The mandatory anomaly rule then logs `Blocked` (Prevention) or `Detected`
(Detection).

### Modes and the rollout workflow **(verified)**

- **Detection:** log only. Never blocks.
- **Prevention:** blocks with **403**.

Always deploy new WAF in **Detection first**, read the logs, add exclusions and
custom rules for false positives, *then* switch to Prevention.

### Customization

- **Exclusions:** omit request attributes (headers, cookies, args, body fields)
  from inspection. Use these for false positives such as auth tokens or password
  fields. Exclude the narrowest thing possible, not the whole rule.
- **Custom rules:** match conditions (IP, geo via `GeoMatch`, headers, URI, body,
  etc.), a priority, and an action. Rate limiting is a custom-rule type on v2
  (confirm current availability and limits).
- **Request body inspection:** can inspect JSON and XML. Request size limits
  are configurable with lower and upper bounds (confirm exact numbers in your
  policy settings).

### WAF tuning loop

```
Detection mode -> generate representative traffic -> read AGWFirewallLogs / WAF logs
  -> group by ruleId + requestUri -> decide: real attack, or false positive?
  -> false positive: add a narrow exclusion (or disable that single rule)
  -> repeat until quiet -> switch to Prevention -> keep watching for blocks
```

## 2.11 Monitoring and logs

Enable **diagnostic settings** to Log Analytics:

- **Access log:** every request (status, backend, timings, client IP).
- **Firewall (WAF) log:** every rule hit (`ruleId`, `message`, `action`,
  `policyScope`).
- **Performance log:** *not supported in v2*. Use metrics instead.

Useful metrics: **Healthy/Unhealthy host count**, **Failed requests**,
**Backend response status**, **Total requests**, **Compute units** and
**Capacity units** (scaling), **Backend last-byte response time**, **Application
gateway total time**.

KQL (legacy `AzureDiagnostics` form; resource-specific tables like
`AGWAccessLogs` and `AGWFirewallLogs` exist too, and column names differ):

```kusto
// Requests by status over the last hour
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and OperationName == "ApplicationGatewayAccess"
| where TimeGenerated > ago(1h)
| summarize count() by httpStatus_d

// Which WAF rules are firing, and where
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and OperationName == "ApplicationGatewayFirewall"
| where TimeGenerated > ago(24h)
| summarize hits = count() by ruleId_s, action_s, requestUri_s
| order by hits desc

// Slow backends
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and OperationName == "ApplicationGatewayAccess"
| summarize p95 = percentile(timeTaken_d, 95) by bin(TimeGenerated, 5m)
```

## 2.12 Build one with the CLI (lab-sized)

Flags drift between CLI versions, so check `--help` as you go.

```bash
RG=rg-agw-lab; LOC=eastus
az group create -n $RG -l $LOC

az network vnet create -g $RG -n vnet-lab --address-prefixes 10.0.0.0/16
az network vnet subnet create -g $RG --vnet-name vnet-lab -n snet-agw --address-prefixes 10.0.1.0/24
az network vnet subnet create -g $RG --vnet-name vnet-lab -n snet-app --address-prefixes 10.0.2.0/24

az network public-ip create -g $RG -n pip-agw --sku Standard --allocation-method Static

# WAF policy first, in Detection mode (see 2.10 rollout workflow)
az network application-gateway waf-policy create -g $RG -n waf-lab
az network application-gateway waf-policy policy-setting update \
  -g $RG --policy-name waf-lab --state Enabled --mode Detection

# The gateway: WAF_v2, 2 fixed instances, one HTTP listener, backend = 2 IPs
az network application-gateway create -g $RG -n agw-lab \
  --sku WAF_v2 --capacity 2 --priority 100 \
  --vnet-name vnet-lab --subnet snet-agw --public-ip-address pip-agw \
  --waf-policy waf-lab \
  --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http \
  --servers 10.0.2.4 10.0.2.5

# Is the backend healthy?
az network application-gateway show-backend-health -g $RG -n agw-lab -o table
```

Then explore: add a custom probe, an HTTPS listener with a Key Vault cert, a
path-based rule, a rewrite rule set, and a custom WAF rule that blocks a
country, and watch each change in the logs.

---

# Part 3: Azure Firewall

## 3.1 SKUs (verified)

| | Basic | Standard | Premium |
|---|---|---|---|
| Target | SMB, light traffic | Enterprise L3-L7 | Highly sensitive / regulated (e.g. payment processing) |
| Throughput | up to **250 Mbps** | up to **30 Gbps** | up to **100 Gbps** |
| Fat flow (single flow) | n/a | 1 Gbps | 10 Gbps |
| Stateful L3-L4 (5-tuple) | yes | yes | yes |
| App-level FQDN filtering (HTTP/S/SQL, SNI) | yes | yes | yes |
| **Network-level FQDN filtering** (all ports/protocols) | no | yes | yes |
| DNS proxy + custom DNS | no | yes | yes |
| Web categories | no | yes | yes |
| Threat intelligence | **Alert only** | alert + deny | alert + deny |
| **IDPS** | no | no | **yes** |
| **Outbound TLS inspection** (forward proxy) | no | no | **yes** |
| **URL filtering** (full path, with TLS inspection) | no | no | **yes** |
| Inbound TLS termination | n/a | n/a | via **Application Gateway** |
| Availability zones, central mgmt, logging, forced tunneling | yes | yes | yes |

Pricing has two parts per SKU: a fixed **hourly deployment charge** and a
**per-GB data-processing charge**. Cost rises Basic < Standard < Premium. Choose
the lowest SKU that meets your throughput and security needs, and see the pricing
page for current rates.

## 3.2 Deployment model

**Subnets and resources (verified)**

- Subnet must be named exactly **`AzureFirewallSubnet`**, minimum **/26**. A /26
  is enough for all scaling scenarios, so the size never needs to grow.
- **NSGs on `AzureFirewallSubnet` are not supported and are disabled.** The
  service has its own platform protection.
- **`AzureFirewallManagementSubnet`** (also /26, confirm) plus a management public
  IP is required for **Basic** and for **forced-tunneling** deployments (confirm
  the Basic requirement; the FAQ only states that Basic supports forced
  tunneling and that forced tunneling uses a management NIC). This lets the
  firewall reach the internet for its own management even if the data path is
  tunneled or has no public IP.
- Firewall and VNet must be in the **same resource group** and **same
  subscription**. The public IP may be in another resource group. Firewall names
  are limited to **50 characters**.
- **Availability zones:** configure at deployment. Changing afterwards requires
  deallocating, and all public IPs must use the same zones.
- **No public IP:** possible only in **forced-tunneling mode** (management NIC with
  its own public IP; data path can be private).

**Topologies**

- **Hub-and-spoke** is the normal model: one firewall in a hub VNet, spokes
  peered, spokes route `0.0.0.0/0` to the firewall. One firewall per region is
  the recommendation. Global VNet peering across regions is supported but not
  recommended for latency and performance reasons.
- **Virtual WAN secured hub:** the firewall lives in a vWAN hub. Not every
  reconfiguration option works there (for example, zones can't be changed after
  deployment).
- **Firewall Manager** manages policies centrally across firewalls and hubs.

## 3.3 Firewall Policy

A **Firewall Policy** is the modern way to manage rules. Classic rules are the
older, per-firewall model. Policies are reusable, and they support inheritance.

```
Firewall Policy
 |- Rule Collection Group (RCG)      priority 100 (highest) .. 65000 (lowest)
     |- Rule Collection              priority, action (Allow/Deny), type
         |- Rules                    all rules in a collection are the same type
```

- Collection **types: DNAT, Network, Application.** You can mix types inside one
  RCG, but each collection has one type.
- **Hierarchy:** a **child** policy inherits from a **parent**. The parent's RCGs
  **always** take precedence, regardless of priority numbers in the child. Use
  this for a central security baseline that app teams cannot override.
- **IP Groups** let you reuse sets of addresses across rules. They can't be moved
  between resource groups.
- Space priorities in increments of 100 so you can insert later.

## 3.4 Rule processing order (verified, the thing to memorize)

By default, **everything is denied** until a rule allows it. Rules are
**terminating**: processing stops at the first match.

The firewall makes three passes, in this order, **regardless of RCG or collection
priority and regardless of inheritance**:

1. **DNAT** rules
2. **Network** rules
3. **Application** rules

Within each pass: parent policy first, then RCGs by priority, then collections by
priority. Then:

4. The built-in **infrastructure rule collection** (allowed platform FQDNs, e.g.
   Platform Image Repository, managed-disk status, diagnostics). It is processed
   after application rules and before the final deny-all.
5. **Deny all** (implicit).

Special ordering notes:

- **Threat intelligence** (if enabled) has the **highest priority**. It runs
  before network and application rules and can drop traffic before any of your
  rules see it.
- **IDPS in Alert mode** runs in *parallel* with rules. **Alert and Deny** runs
  inline *after* rule matching, and drops silently (no TCP RST). So a flow that a
  rule allowed can still get dropped by IDPS, with a second log entry.
- **If a network rule matches, application rules are never evaluated for that
  flow.** The classic gotcha: a broad network rule (`*` to ports 80,443) makes
  your FQDN deny rule irrelevant.

Worked example, straight from the docs: a network rule *Allow TCP * -> * : 80,443*
and an application rule *Deny google.com* means **google.com is allowed**, because
the network rule matches first and processing stops.

## 3.5 The three rule types in detail

### Network rules

- Source, destination (IP, CIDR, **service tag**, **IP Group**, or **FQDN**),
  protocol (TCP, UDP, ICMP, Any), ports.
- **FQDNs in network rules require DNS proxy to be enabled** on the firewall
  (confirm for your SKU).
- Protocol *Any* means all IANA IP protocols (and a configured destination port
  turns it into TCP+UDP). Before Nov 9, 2020 *Any* meant only TCP/UDP/ICMP, so
  older rules may be broader than you want. Be explicit.
- Network rules **don't SNAT between private ranges** and **preserve the original
  source IP** in logs. Prefer them over app rules if you need source IP visibility
  for FQDN traffic.

### Application rules

- Match on **FQDN**, **FQDN tag** (e.g. WindowsUpdate, AzureKubernetesService),
  **web category** (Standard+), or **URL** (Premium).
- **Only for HTTP, HTTPS, and MSSQL** traffic. Everything else must be a network
  rule.
- **Matching uses the Host header (HTTP) or SNI (HTTPS), not the destination IP.**
  The firewall resolves the name via DNS and uses *that* IP. If the actual TCP
  port doesn't match the port in the host header, traffic is dropped.
- Without TLS inspection, HTTPS filtering is **SNI-only** (no path/URL). Full URL
  filtering needs **Premium + TLS inspection**.
- **Traffic matched by application rules is always SNATed** to the firewall
  (so the backend sees the firewall instance IP, and the firewall adds an
  `X-Forwarded-For` header with the original source for HTTP and inspected
  HTTPS).
- **Wildcards** **(verified)**: `*` only works on the **left-most** side of an FQDN
  (`*.contoso.com`). `*.contoso.com` does **not** match `contoso.com` itself, so
  add both. `www.contoso.*` and `*.contoso.*` are **not** supported. URL rules
  can end with `/*` (`www.contoso.com/test/*`), but not contain query strings or
  ports.

### DNAT rules

- Publish an inbound port: public IP:port to private IP:port.
- DNAT is **processed before network rules**, and a DNAT match is implicitly
  allowed, so no separate allow rule is needed.
- **Restrict the source** (don't use `*`) on DNAT rules. Docs recommend a
  specific Internet source.
- **Application rules are never applied to inbound connections.** For inbound
  HTTP/S filtering, use a WAF.
- DNAT'd traffic is SNATed to the firewall's private IP, so the backend sees the
  firewall as the client.

## 3.6 SNAT, DNAT, and ports (verified unless noted)

- **No SNAT** when the destination is a private range per **RFC 1918** or
  **RFC 6598** (`100.64.0.0/10`). If your organization uses public IP ranges
  *privately*, the firewall will SNAT to them unless you configure **Private IP
  ranges (SNAT)** to exclude them. There is also an **auto-learn SNAT routes**
  option that uses Azure Route Server.
- Internet-bound traffic is SNATed to the firewall's public IP(s).
- **SNAT port exhaustion** is a real production failure ("intermittent outbound
  failures under load"). Two fixes: attach **more public IPs** (cheaper), or use
  **Azure NAT Gateway** (more scalable and robust). Ports are reused immediately
  after a connection closes (no idle wait). Per-IP port counts: confirm the
  current figure in the docs.
- **TCP idle timeout is 4 minutes** by default. It isn't user-configurable, but
  Support can raise it up to **15 minutes** for inbound/outbound (not east-west).
  Idle connections are closed with a TCP RST. Use TCP keep-alives in long-lived
  clients.
- **Connections:** each firewall VM supports about **250k** active connections;
  total = 250k x number of VMs in the backend pool.

## 3.7 DNS proxy

- With **DNS proxy** on, the firewall answers DNS for clients. Spokes point their
  VNet DNS at the firewall's private IP.
- It's required for **FQDN-in-network-rules**. It also keeps client and firewall
  FQDN resolution consistent, which avoids "works from my VM but blocked at the
  firewall" mismatches caused by differing DNS answers.

## 3.8 Threat intelligence, IDPS, TLS inspection

- **Threat intelligence:** filters known-malicious IPs and domains using Microsoft's
  feed. Modes: Off, **Alert**, **Alert and deny**. Basic supports alert only.
  Allow-list specific FQDNs/IPs if you get false positives.
- **IDPS (Premium):** signature-based detection and prevention. Modes: Alert, or
  Alert and Deny. Supports per-signature overrides. **Direction depends on
  "private IP ranges for IDPS."** Traffic from private ranges is treated as
  internal and some inbound signatures won't apply (see Part 4).
- **TLS inspection (Premium):** the firewall decrypts and re-encrypts outbound
  TLS. It needs an **intermediate CA certificate** (stored in Key Vault, accessed
  by a managed identity) that your clients **trust**. Without client trust, you
  get certificate errors. It is practical for **outbound/internal** traffic.
  It is *not* suitable for internet-facing inbound, because the firewall would
  present its own certificate to public clients.

## 3.9 Routing

**Send spoke traffic to the firewall with a UDR:**

```
Route table on each spoke subnet
  0.0.0.0/0  -> Next hop type: VirtualAppliance, IP: <firewall private IP>
  Disable "Propagate gateway routes" if on-prem routes would otherwise override
```

**The firewall subnet itself needs direct internet reachability.** If
`AzureFirewallSubnet` learns a default route via BGP (ExpressRoute/VPN), override
it with `0.0.0.0/0 -> Internet` on that subnet. For real forced tunneling, use the
management NIC (3.2).

**Routes between subnets in the same VNet:** if you use the whole VNet prefix as
a UDR destination, intra-subnet traffic also goes via the firewall. Add a more
specific route for the subnet itself with next hop type `VirtualNetwork`. For
plain subnet-to-subnet segmentation, prefer **NSGs** (no UDRs needed).

### Asymmetric routing (the #1 hub-spoke bug) **(verified)**

The Azure firewall sits behind an internal load balancer front-end IP. A backend
that receives traffic from one specific firewall instance (say `.7`) must return
it to **the same instance**. If a spoke UDR sends return traffic to the firewall's
*front-end* IP (`.4`), the load balancer may deliver it to a *different* instance
that has no session, and the flow breaks.

Fix: in spoke UDRs, list **only the subnets that need to go through the firewall**.
Never use a broad prefix that includes the **firewall subnet** (or the App Gateway
subnet) itself. This applies equally to App Gateway and any NVA in the hub.

## 3.10 Scaling and operations (verified)

- **Autoscaling:** scales out when average **throughput or CPU hits ~60%**, or
  **connections reach ~80%**. Starts with two instances. Initial capacity about
  2.5-3 Gbps, up to 30 Gbps (Standard) or 100 Gbps (Premium).
- **Scale-out takes ~5-7 minutes.** When load testing, run **10-15+ minutes** and
  open *new* connections to actually reach the new nodes.
- **Maintenance and failures:** active-active with connection draining (existing
  connections get 90s: 45s no new connections, then RSTs). Unplanned node failures
  recover in roughly 10 seconds. You can configure a **customer-controlled
  maintenance window** (minimum 5 hours, daily, one config per firewall, all
  SKUs).
- **Stop/start:** you can deallocate to stop billing, but the **private IP may
  change**, which can break UDRs. Re-check routes after restarting.
- **Rule changes that deny previously allowed traffic drop existing sessions.**
- **Provisioning state `Failed`:** one or more backend instances failed to take a
  config update. The firewall keeps running but may be inconsistent. Retry the
  update until it shows `Succeeded`.
- **AD access is blocked by default.** Allow the `AzureActiveDirectory` service tag
  for Entra ID/AD flows.
- **TCP ping quirk:** when no rule allows a destination, a TCP ping can still
  "succeed" because the firewall itself answers (and doesn't log it). It's not a
  real connection. Likewise on ports 80/443/1433 the firewall acts as a passive
  listener and doesn't log bare SYNs, only real HTTP/TLS payloads.

## 3.11 Logging and KQL

Send logs to Log Analytics (also Storage or Event Hub). Prefer the
**resource-specific ("structured") tables**:

| Table | Contents |
|---|---|
| `AZFWNetworkRule` | Network rule hits (allow and deny) |
| `AZFWApplicationRule` | Application rule hits (FQDN, URL, category) |
| `AZFWNatRule` | DNAT hits |
| `AZFWThreatIntel` | Threat intelligence hits |
| `AZFWIdpsSignature` | IDPS alerts/drops (Premium) |
| `AZFWDnsQuery` | DNS proxy queries |
| `AZFWFqdnResolveFailure` | FQDN rules that failed DNS resolution |

(Column names vary slightly. Verify with `| getschema`.)

```kusto
// What is being DENIED, and by which rule?
AZFWNetworkRule
| where TimeGenerated > ago(1h) and Action == "Deny"
| summarize hits = count() by SourceIp, DestinationIp, DestinationPort, Protocol
| order by hits desc

// Outbound web destinations by FQDN
AZFWApplicationRule
| where TimeGenerated > ago(24h)
| summarize hits = count() by Fqdn, Action
| order by hits desc

// FQDN rules that can't resolve (DNS-proxy or DNS misconfiguration)
AZFWFqdnResolveFailure
| where TimeGenerated > ago(24h)
| summarize count() by Fqdn
```

Enable **Policy Analytics** (in Firewall Policy) to find unused, overlapping, or
shadowed rules over time, and to get rule-optimization suggestions.

## 3.12 Build one with the CLI (lab-sized)

The `az network firewall` command group may require the `azure-firewall`
extension on older CLIs. Check `--help`.

```bash
RG=rg-fw-lab; LOC=eastus
az group create -n $RG -l $LOC

az network vnet create -g $RG -n vnet-hub --address-prefixes 10.1.0.0/16
az network vnet subnet create -g $RG --vnet-name vnet-hub -n AzureFirewallSubnet --address-prefixes 10.1.0.0/26
az network vnet subnet create -g $RG --vnet-name vnet-hub -n snet-workload       --address-prefixes 10.1.1.0/24

az network public-ip create -g $RG -n pip-fw --sku Standard --allocation-method Static

# Policy first, then the firewall that uses it
az network firewall policy create -g $RG -n fwp-lab --sku Standard
az network firewall create -g $RG -n fw-lab --sku AZFW_VNet --tier Standard \
  --firewall-policy fwp-lab --vnet-name vnet-hub --conf-name ipconf --public-ip pip-fw

FW_IP=$(az network firewall show -g $RG -n fw-lab \
  --query "ipConfigurations[0].privateIPAddress" -o tsv)

# Rule collection group + an application rule: allow only *.microsoft.com over HTTPS
az network firewall policy rule-collection-group create -g $RG --policy-name fwp-lab \
  -n rcg-base --priority 200
az network firewall policy rule-collection-group collection add-filter-collection \
  -g $RG --policy-name fwp-lab --rcg-name rcg-base \
  --name allow-ms --collection-priority 1000 --action Allow \
  --rule-name ms-https --rule-type ApplicationRule \
  --source-addresses 10.1.1.0/24 --protocols Https=443 --target-fqdns "*.microsoft.com"

# Route the workload subnet through the firewall
az network route-table create -g $RG -n rt-workload --disable-bgp-route-propagation true
az network route-table route create -g $RG --route-table-name rt-workload -n default \
  --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address "$FW_IP"
az network vnet subnet update -g $RG --vnet-name vnet-hub -n snet-workload --route-table rt-workload
```

Test from a VM in `snet-workload`: `curl https://www.microsoft.com` works,
`curl https://example.com` is blocked (default deny), and the denial appears in
`AZFWApplicationRule`.

---

# Part 4: Using them together

## 4.1 The decision tree (from Microsoft's architecture guide, verified)

```
Is the app published via HTTP(S) from the internet?
 |- No  -> Azure Firewall only (DNAT for inbound, rules for outbound)
 |- Yes -> Does the firewall need to inspect App Gateway -> backend traffic
           (IDPS / TLS inspection), OR must the app see the client source IP?
            |- Neither -> PARALLEL design
            |- Either  -> APP GATEWAY IN FRONT OF FIREWALL design
```

## 4.2 Design A: Parallel (the common default)

```
Internet -> Application Gateway (WAF) -> backend VMs            (inbound web)
Backend VMs -> UDR 0.0.0.0/0 -> Azure Firewall -> Internet      (outbound, all)
Internet -> Azure Firewall (DNAT) -> VMs                         (inbound non-web)
```

- Web traffic goes through **App Gateway only**. Non-web inbound and **all
  outbound** go through the firewall.
- Backend subnet UDR `0.0.0.0/0 -> firewall` handles egress. The App Gateway
  subnet has **no** such UDR.
- Return traffic from the backend to App Gateway stays inside the VNet (standard
  routing), so there is no asymmetric-routing problem.
- Client IP: visible in `X-Forwarded-For`.
- Best for typical web apps, and the **recommended pairing for AKS**.
- Downside: the firewall does *not* inspect inbound web traffic.

## 4.3 Design B: App Gateway in front of Firewall (inspect everything)

```
Internet -> App Gateway (WAF) -> [UDR] -> Azure Firewall -> backend
```

- Use when you want WAF **and** firewall inspection (IDPS) of web traffic, and the
  app needs the client IP.
- **UDRs:** the App Gateway subnet gets a route for the **backend subnet prefix**
  (specific, **not** `0.0.0.0/0`) -> firewall. The backend subnet routes
  `0.0.0.0/0` and the App Gateway subnet prefix -> firewall, so returns come back
  via the firewall.
- The firewall doesn't SNAT private destinations. If an **application rule**
  matches, the backend sees the *firewall instance* IP as the source. Network
  rules show the App Gateway instance IP. In both cases the client IP is preserved
  in `X-Forwarded-For`.
- **IDPS gotcha (verified):** the firewall sees the App Gateway subnet's *private*
  source IPs and treats them as internal, so it **skips inbound IDPS rules**.
  Fix: edit the firewall policy's **IDPS private IP ranges** so the App Gateway
  subnet is *not* considered internal.
- For end-to-end HTTPS inspection, this design needs **Firewall Premium with TLS
  inspection**.
- Variation: **private DNAT** on the firewall removes the need for the backend UDRs.
  The firewall IP is then the source, and the real client IP is still in the
  `X-Forwarded-For` header.

## 4.4 Design C: Firewall in front of App Gateway (rarely right)

```
Internet -> Azure Firewall (DNAT) -> App Gateway (WAF) -> backend
```

- Gives one shared public IP for everything and lets the firewall drop junk (threat
  intel) before it reaches App Gateway.
- **Big drawback:** for internet clients, DNAT/SNAT hides the original client IP
  (no `X-Forwarded-For` unless TLS inspection is on, and TLS inspection means
  presenting the firewall's own certificate to public users, which breaks
  browsers). The firewall mostly sees encrypted traffic anyway.
- It's mainly suited to *internal* apps, or when an upstream WAF (such as Front
  Door) already captured the client IP.

## 4.5 Hub-and-spoke notes (verified)

- App Gateways and API Management gateways are often deployed in **spokes** by
  application teams, with the firewall in the hub.
- You **can't** use a static route with next hop type `VirtualNetwork` across
  peered VNets. It only applies to the local VNet.
- Keep spoke UDRs free of the firewall subnet and App Gateway subnet prefixes.
  See 3.9.

## 4.6 AKS specifics

- **Inbound:** App Gateway (AGIC) or **Application Gateway for Containers** with
  WAF. For AKS the guidance is the **parallel** design.
- **Outbound:** Azure Firewall with the **`AzureKubernetesService` FQDN tag** to
  allow only what the control plane and nodes need. See "Limit network traffic
  with Azure Firewall in AKS."
- With **kubenet + AGIC** you need a route table on the App Gateway subnet for pod
  CIDR routing (that is one of the supported v2 UDR scenarios). Azure CNI doesn't
  need it.

---

# Part 5: Security and cost checklist

**Application Gateway / WAF**

- [ ] WAF_v2 for anything internet-facing. Run in **Detection**, tune, then
      **Prevention**.
- [ ] TLS 1.2+ policy. Certs from **Key Vault** with managed identity.
- [ ] End-to-end TLS where traffic crosses untrusted network segments.
- [ ] Min capacity >= 2 and zones enabled for production.
- [ ] Subnet is /24, NSG has GatewayManager 65200-65535, no `0.0.0.0/0` UDR to a
      firewall.
- [ ] Diagnostics to Log Analytics (access + firewall logs); alert on unhealthy
      host count and WAF `Blocked` spikes.
- [ ] Custom error page for 403/502 (don't leak default error text).
- [ ] Backend only accepts traffic from the gateway subnet (NSG on the backend),
      so nobody bypasses the WAF.

**Azure Firewall**

- [ ] **Firewall Policy** (not classic rules), with a parent baseline policy.
- [ ] Right SKU. Premium only where IDPS/TLS inspection is actually used.
- [ ] Threat intelligence on **Alert and deny**.
- [ ] DNS proxy on if you use FQDNs in network rules.
- [ ] Multiple public IPs or NAT Gateway to avoid SNAT exhaustion.
- [ ] Zones enabled. One firewall per region.
- [ ] Spoke UDRs exclude the firewall subnet and App Gateway subnet prefixes.
- [ ] Structured logs on, Policy Analytics reviewed periodically.
- [ ] Don't use broad "allow `*` to `*` : 80,443" network rules. They bypass every
      application rule.
- [ ] Enable **DDoS Protection** on perimeter VNets (Microsoft recommends it on
      every perimeter virtual network).

**Cost levers**

- Firewall cost = hourly deployment + per-GB processed. Fewer firewalls (hub model)
  saves money but adds peering cost, so evaluate traffic patterns.
- Deallocate lab firewalls when not in use (and re-check UDRs: the private IP can
  change).
- App Gateway cost = fixed + capacity units. Right-size min/max capacity.
- Lab tip: **delete the resource group** when done. Both services bill hourly even
  when idle.

---

# Part 6: Troubleshooting runbooks

## 6.1 Application Gateway

| Symptom | Likely causes | How to confirm / fix |
|---|---|---|
| **502 Bad Gateway** | All backends unhealthy; NSG/UDR blocking gateway->backend; backend cert not trusted (end-to-end TLS); probe host mismatch | `show-backend-health`; check NSG on backend subnet; check probe host/path/codes; upload trusted root cert |
| **502 intermittent** | Backend closing connections early / keep-alive mismatch; backend resets under load | Compare backend keep-alive timeout vs gateway; check backend logs |
| **504 Gateway Timeout** | Backend slower than request timeout | Raise backend-settings **request timeout**; fix slow backend |
| **403 from the gateway** | WAF blocked it | Query the WAF firewall log for the request `transactionId`/`ruleId`; add narrow exclusion or tune rule |
| **Backend health = Unknown** | UDR on the App Gateway subnet, NSG missing GatewayManager 65200-65535, or Azure Load Balancer probe blocked | Remove UDR; fix NSG |
| **Backend sees wrong host / app returns 404/redirect loop** | Host header not preserved or overridden unexpectedly | Fix "override host name" in backend settings; preserve original host for apps that need it |
| **Real client IP missing in app logs** | App reads socket IP, not `X-Forwarded-For` | Read `X-Forwarded-For`; configure the web server's trusted-proxy setting |
| **Can't deploy: subnet error** | Other resources in subnet, v1/v2 mix, insufficient permissions | Dedicated /24; give `subnets/join/action` |
| **DNS changes not honored** | VNet DNS changed, gateway not restarted | Stop and Start the gateway |
| **Large upload fails** | WAF request-size/file-upload limit | Raise limit in WAF policy, or exempt that path |

## 6.2 Azure Firewall

| Symptom | Likely causes | How to confirm / fix |
|---|---|---|
| **Everything blocked** | Default deny; no allow rule | Check `AZFWNetworkRule`/`AZFWApplicationRule` for the denied flow |
| **FQDN rule "doesn't work"** | Network rule matched first (app rules skipped); app rule is for non-HTTP(S) traffic; DNS answer mismatch; wildcard doesn't cover apex | Check rule order (DNAT -> Network -> App); enable DNS proxy; add apex FQDN too |
| **Works then breaks randomly** | **Asymmetric routing** (spoke UDR includes the firewall subnet) | Narrow the spoke UDR prefixes (3.9) |
| **Intermittent outbound failures under load** | **SNAT port exhaustion** | Add public IPs or NAT Gateway; check SNAT metrics |
| **Long-lived connections drop** | 4-minute idle timeout | TCP keep-alive; ask Support to raise it (max 15 min) |
| **Web traffic fine, other ports blocked** | App rules only handle HTTP/HTTPS/MSSQL | Add network rules for other ports |
| **DNAT works but app sees the firewall IP** | DNAT is SNATed to the firewall's private IP | Expected; use `X-Forwarded-For` upstream if needed |
| **TLS inspection cert errors** | Clients don't trust the intermediate CA | Distribute the CA to clients/devices |
| **Premium IDPS not firing for App GW traffic** | App Gateway subnet is in the IDPS "private ranges" | Edit IDPS private ranges (4.3) |
| **After restart, routing broken** | Firewall private IP changed after deallocate/allocate | Update UDR next-hop |
| **Provisioning state Failed** | Config update failed on some instances | Re-apply the update until `Succeeded` |

## 6.3 General network diagnostic toolbox

- **Network Watcher > Next hop**: where does a packet from this VM go?
- **Effective routes** (on the NIC): which UDR/BGP/system route wins?
- **Effective security rules** (NIC): combined NSG verdict.
- **IP flow verify**: would an NSG allow this specific 5-tuple?
- **Connection troubleshoot / connection monitor**: end-to-end reachability and
  latency.
- Packet capture on the VM when you need to *prove* where a packet died.

```bash
# Backend health on App Gateway
az network application-gateway show-backend-health -g <rg> -n <agw>

# Effective routes for a VM NIC
az network nic show-effective-route-table -g <rg> -n <nic> -o table
```

---

# Part 7: Labs, a learning path, and self-test

## 7.1 Progressive labs

Do these in order in a sandbox subscription. Delete the resource group after each
one to avoid hourly charges.

1. **App Gateway basics.** Build the 2.12 gateway with two backend VMs running a
   simple web server. Hit the public IP. Break a backend and watch
   `show-backend-health` and the 502 behavior.
2. **Probes and host headers.** Point a backend at an Azure App Service. Make it
   fail with a host-header mismatch, then fix it using backend-settings host
   override and a custom probe.
3. **TLS.** Add an HTTPS listener with a self-signed cert, then a Key Vault cert via
   managed identity. Then switch to end-to-end TLS and fix the trusted-root
   requirement.
4. **Routing.** Multi-site (two host names, one gateway) and path-based (`/api/*`).
   Add an HTTP-to-HTTPS redirect.
5. **WAF.** Switch to Detection, send `?id=1' OR '1'='1` and a script tag, read the
   logs, then move to Prevention and confirm the 403. Add an exclusion for a fake
   false positive and a custom rule that blocks by IP/country.
6. **Firewall egress.** Build the 3.12 lab. Allow only `*.microsoft.com`. Prove
   `example.com` is blocked and find the deny in KQL.
7. **Rule ordering.** Create the docs' Example 1 (broad network allow + app deny)
   and *prove* the app deny never fires. Then fix it.
8. **Asymmetric routing on purpose.** Add a broad spoke UDR that includes the
   firewall subnet, watch sessions break, and repair it with specific prefixes.
9. **Combine them.** Implement Design B (App Gateway in front of Firewall) with the
   specific-prefix UDRs, then Premium IDPS, and confirm the IDPS private-range
   caveat in the logs.
10. **SNAT.** Generate lots of outbound connections, observe SNAT behavior, then add
    public IPs or a NAT Gateway.

## 7.2 Self-test: you've "mastered" it when you can answer these without notes

1. Why can't an App Gateway v2 subnet have `0.0.0.0/0` pointing to a firewall?
2. What's the NSG rule that must exist for App Gateway v2, and what happens if
   you omit it?
3. What's the recommended v2 subnet size and why?
4. In Azure Firewall, a network rule allows TCP `*:443` and an application rule
   denies `badsite.com`. Is `badsite.com` blocked? Why?
5. What order does the firewall process DNAT, network, and application rules,
   and does priority override that order?
6. How does a parent policy interact with a child policy's priorities?
7. Your app behind App Gateway logs the gateway's IP for every request. How do
   you recover the real client IP?
8. CRS anomaly scoring: why is one Warning match not enough to block, but a
   Warning plus a Notice is?
9. What do you do before switching a new WAF to Prevention mode?
10. Why might a spoke UDR for `10.0.0.0/8 -> firewall` cause random failures?
11. What's SNAT port exhaustion, and the two fixes?
12. When is "App Gateway in front of Firewall" required instead of the parallel
    design?
13. Why does the IDPS caveat exist in that design, and what's the fix?
14. Why can't you filter inbound HTTP/S with Azure Firewall *application rules*?
15. What are the differences between Firewall Basic, Standard, and Premium that
    would change your SKU choice?

(Answers are all in this document. If you stall, the section is cited by topic
above.)

## 7.3 Top 12 mistakes, in one place

1. Sending `0.0.0.0/0` from the App Gateway v2 subnet to a firewall.
2. Putting a **UDR** on the App Gateway subnet "just in case" and losing backend
   health/logs.
3. Missing `GatewayManager` 65200-65535 in the App Gateway NSG.
4. Using a /26 for an App Gateway v2 subnet (that's the *v1* number).
5. Jumping straight to **WAF Prevention** without a Detection-mode tuning period.
6. Probe host header not matching what the backend expects, so everything is
   "unhealthy."
7. A broad **network rule** that silently bypasses every **application rule**.
8. Spoke UDRs that include the **firewall subnet** prefix, producing asymmetric
   routing.
9. Forgetting `*.example.com` doesn't match `example.com`.
10. Expecting the firewall to filter **inbound** HTTP/S with application rules
    (it doesn't, use a WAF).
11. Ignoring SNAT port exhaustion until production traffic hits.
12. Leaving lab firewalls and gateways running. They bill hourly.

---

# References

All pages are on Microsoft Learn (learn.microsoft.com). Use these as the source of
truth when numbers or versions here disagree.

- Application Gateway v2 overview: `/azure/application-gateway/overview-v2`
  (updated 2026-09)
- Application Gateway infrastructure configuration (subnet, NSG, UDR):
  `/azure/application-gateway/configuration-infrastructure` (updated 2026-08)
- Application Gateway private deployment:
  `/azure/application-gateway/application-gateway-private-deployment`
- WAF on Application Gateway overview: `/azure/web-application-firewall/ag/ag-overview`
  (updated 2026-08)
- DRS and CRS rule groups:
  `/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules`
- Azure Firewall: choose a SKU: `/azure/firewall/choose-firewall-sku` (updated 2026-07)
- Azure Firewall rule processing logic: `/azure/firewall/rule-processing`
  (updated 2026-04)
- Azure Firewall FAQ: `/azure/firewall/firewall-faq` (updated 2026-09)
- Azure Firewall SNAT private ranges: `/azure/firewall/snat-private-range`
- Azure Firewall Premium features (IDPS, TLS inspection):
  `/azure/firewall/premium-features`
- Firewall + Application Gateway architectures:
  `/azure/architecture/example-scenario/gateway/firewall-application-gateway`
  (updated 2026-09)
- Limit AKS egress with Azure Firewall: `/azure/aks/limit-egress-traffic`
- Azure limits and quotas (Firewall/App Gateway sections):
  `/azure/azure-resource-manager/management/azure-subscription-service-limits`
