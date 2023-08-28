## Storage Accounts
|Type of storage account|Supported storage services | Redundancy options | Usage |
|-----------------------|---------------------------|--------------------|-------|
|Standard general-purpose v2|Blob Storage (including Data Lake Storage1), Queue Storage, Table Storage, and Azure Files| Locally redundant storage (LRS) / geo-redundant storage (GRS) / read-access geo-redundant storage (RA-GRS) Zone-redundant storage (ZRS) / geo-zone-redundant storage (GZRS) / read-access geo-zone-redundant storage (RA-GZRS)2|Locally redundant storage (LRS) / geo-redundant storage (GRS) / read-access geo-redundant storage (RA-GRS) |
| Premium block blobs3 | Blob Storage (including Data Lake Storage1) | LRS ZRS2 |Premium storage account type for block blobs and append blobs. Recommended for scenarios with high transaction rates or that use smaller objects or require consistently low storage latency. Learn more about example workloads. |
