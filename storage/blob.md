## 
```
root@minikube02:~# az storage blob list     --account-name openmetadata     --container-name openmetablob     --output table
No connection string, account key or sas token found, we will query account keys for your storage account. Please try to use --auth-mode login or provide one of the following parameters: connection string, account key or sas token for your storage account.
Name           Blob Type    Blob Tier    Length    Content Type              Last Modified              Snapshot
-------------  -----------  -----------  --------  ------------------------  -------------------------  ----------
blob.txt       BlockBlob    Hot          36        text/plain                2023-08-31T12:07:14+00:00
examples.conf  BlockBlob    Hot          2597      application/octet-stream  2023-08-31T12:07:14+00:00
logstash.conf  BlockBlob    Hot          463       application/octet-stream  2023-08-31T12:07:14+00:00
nginx.conf     BlockBlob    Hot          725       application/octet-stream  2023-08-31T12:07:14+00:00
```
