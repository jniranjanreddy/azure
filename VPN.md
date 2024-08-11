How to configure VPN  to access Azure resoures Localls

## Source - https://www.youtube.com/watch?v=FqB9-suzKKs&t=511s
## Source - https://www.youtube.com/watch?v=d8KVmhK1_CM&t=1s
## VPN-Client - https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-client


## Three types of VPN's
```
1. Point to site (P2S)
2. Site to Site  (S2S)
3. ExpressRoute  
```




## Point to site Diagram
![image](https://github.com/jniranjanreddy/azure/assets/83489863/b73dbc31-a4fd-4fed-9345-dbeeb5f43ee5)

## Site-to-site
![image](https://github.com/jniranjanreddy/azure/assets/83489863/6ec097d8-cc10-4a14-8cfc-cc62f27e80a4)


# Powershell command to check VPN 
```
# Get-AzVirtualNetworkGateway -ResourceGroupName phs-stg-rg -Name phs-stg-vpn

ResourceGroupName Name        Location       GatewayType VpnType    EnableBgp DisableIPsecProtection EnablePrivateIpAddress ActiveAc
                                                                                                                            tive
----------------- ----        --------       ----------- -------    --------- ---------------------- ---------------------- --------
jnr-stg-rg        jnr-stg-vpn northcentralus Vpn         RouteBased False     False                  False                  False

# $gateway = Get-AzVirtualNetworkGateway -ResourceGroupName jnr-stg-rg -Name jnr-stg-vpn
# PS C:\Users\NJannapureddy> Reset-AzVirtualNetworkGateway -VirtualNetworkGateway $gateway

ResourceGroupName Name        Location       GatewayType VpnType    EnableBgp DisableIPsecProtection EnablePrivateIpAddress ActiveAc
                                                                                                                            tive
----------------- ----        --------       ----------- -------    --------- ---------------------- ---------------------- --------
jnr-stg-rg        jnr-stg-vpn northcentralus Vpn         RouteBased False     False                  False                  False

```
