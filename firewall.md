
## Firewall manager
## Firewall rules


```
How Azure Firewall manages network traffic depends on where the traffic originates:

For allowed inbound traffic, Azure Firewall uses DNAT to translate the firewall's public IP address to the private IP address of the appropriate destination resource in the virtual network.
For allowed outbound traffic, Azure Firewall uses SNAT to translate the source IP address to the firewall's public IP address.


 Note
Azure Firewall uses SNAT only when the destination IP address is outside your virtual network. If the destination IP address is from your virtual network's private address space, Azure Firewall doesn't use SNAT on the traffic.










```
