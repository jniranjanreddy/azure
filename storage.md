## Storage Accounts
```
LRS    - Local Redunat Storage
GRS    - Geo-redundant storage
ZRS    - Zone reduantadt Storage
GZRS   - Geo Zone reduantadt Storage
RAGZRS - read-access geo-zone-redundant storage.

```
## Note: You can't change a storage account to a different type after it's created. To move your data to a storage account of a different type, you must create a new account and copy the data to the new account.

|Type of storage account|Supported storage services | Redundancy options | Usage |
|-----------------------|---------------------------|--------------------|-------|
|Standard general-purpose v2|Blob Storage (including Data Lake Storage1), Queue Storage, Table Storage, and Azure Files| Locally redundant storage (LRS) / geo-redundant storage (GRS) / read-access geo-redundant storage (RA-GRS) Zone-redundant storage (ZRS) / geo-zone-redundant storage (GZRS) / read-access geo-zone-redundant storage (RA-GZRS)2|Locally redundant storage (LRS) / geo-redundant storage (GRS) / read-access geo-redundant storage (RA-GRS) |
| Premium block blobs3 | Blob Storage (including Data Lake Storage1) | LRS ZRS2 |Premium storage account type for block blobs and append blobs. Recommended for scenarios with high transaction rates or that use smaller objects or require consistently low storage latency. Learn more about example workloads. |
| Premium file shares3 | Azure Files | LRS ZRS2 | Premium storage account type for file shares only. Recommended for enterprise or high-performance scale applications. Use this account type if you want a storage account that supports both Server Message Block (SMB) and NFS file shares. |
| Premium page blobs3 | Page blobs only | LRS ZRS2 | Premium storage account type for page blobs only. Learn more about page blobs and sample use cases. |

## Thare are two types of EndPoints
```

```
