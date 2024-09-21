## How to confogure Application Gateway.
```
Source:  https://www.youtube.com/watch?v=QqXRBye8HLI&t=1s
https://www.youtube.com/watch?v=n9uHSHO25cE&t=1s
https://www.youtube.com/watch?v=B3O6bXu-NbM

Step -1
Create Selfsing Certificate.
Powershell Command
 New-SelfSignCertificate -certstorelocation c:\users\user1\Downloads -dnsname www.contso.com 
```
![image](https://github.com/user-attachments/assets/f5f51724-28f8-4ce1-842d-5d1a21b41bde)


```
Generating PSX file.
```
 ![image](https://github.com/user-attachments/assets/0de5dba6-8963-48ca-8e01-1d79bb3b0fc7)

```
What is Azure Application Gateway?
Azure Application Gateway is a Layer 7 (application layer) load balancer designed to manage traffic to web applications1
. It operates at a higher level than traditional load balancers, which typically work at Layer 4 (transport layer).
Key features of Azure Application Gateway include:
Web traffic load balancing: Distributes incoming web traffic across multiple backend servers.
SSL/TLS termination: Offloads SSL/TLS encryption and decryption from backend servers1
.
URL-based routing: Routes traffic based on URL paths to specific backend pools.
Web Application Firewall (WAF): Provides protection against common web vulnerabilities and exploits1
2
.
How Application Gateway Works
Application Gateway sits between internet clients and your backend web servers. It receives requests, processes them based on configured rules, and then forwards them to the appropriate backend servers1
.
Key components:
Frontend IP: The public or private IP address that clients connect to1
.
Listeners: Configure how incoming requests are handled based on protocol, port, and host1
.
Rules: Define how traffic should be routed to backend pools1
.
Backend pools: Groups of servers that handle the incoming requests1
.
HTTP settings: Configure how Application Gateway communicates with backend servers1
.
Deployment and Configuration
To deploy an Azure Application Gateway:
Create a virtual network and subnet for the gateway2
.
Configure frontend IP, listeners, and backend pools2
.
Set up routing rules and health probes2
.
(Optional) Enable and configure WAF for additional security2
.
Integration with Azure Networking
Application Gateway integrates well with other Azure networking components:
Virtual Networks: Deployed within a subnet of your Azure VNet.
Private Link: Enables private connectivity to backend services.
Azure DDoS Protection: Provides additional layer of protection against DDoS attacks.
Hub and Spoke Architecture
While it's possible to deploy Application Gateway in a hub VNet as a shared resource, Microsoft generally recommends deploying it in spoke VNets with the applications it serves. This approach:
Improves troubleshooting of WAF alerts
Avoids hitting Azure Application Gateway limits
Simplifies role-based access control
Advanced Features
URL rewrite rules: Modify request and response headers1
.
Autoscaling: Automatically adjusts capacity based on traffic patterns1
.
Zone redundancy: Spans multiple Availability Zones for high availability1
.
Monitoring and Troubleshooting
Use Azure Network Watcher for diagnostics, logging, and performance monitoring of your Application Gateway5
.
Azure Application Gateway is a crucial component for organizations looking to optimize and secure their web application traffic in Azure. Its rich feature set and deep integration with other Azure services make it a powerful tool for building robust, scalable, and secure web applications.
Related
How does Azure App Gateway integrate with Azure Load Balancer
What are the key differences between Azure App Gateway v1 and v2
Can you explain the role of the Web Application Firewall in Azure App Gateway
How do you configure SSL/TLS offload in Azure App Gateway
What are the best practices for securing Azure App Gateway

```
