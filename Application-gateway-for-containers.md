## https://medium.com/@luca_4339/istio-azure-app-gateway-for-containers-9a025c6d71ff

flowchart LR
  U[User] --> Z[ZPA]
  Z --> D[Private DNS]
  D --> A[AGFC + WAF]
  A --> H[Gateway API HTTPRoute]
  H --> I[Istio ingressgateway Service]
  I --> G[Istio Gateway]
  G --> V[Istio VirtualService]
  V --> S[Service]
  S --> P[Pod / Istio sidecar]

