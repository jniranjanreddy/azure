
```
Source: chat GPT
How to copy a azure data to Storage Account.
1. Create a snapshop
2. in the snap

Prerequisites
Azure role permissions: You need to have permission to read and export disks. The Reader or Contributor role can provide these permissions.
Target storage account: Ensure you have a storage account ready for the exported VHD.
Step-by-Step Guide
Navigate to the Disk in Azure Portal:

Go to Azure Portal > Disks.
Select the disk you want to export.
Generate a Shared Access Signature (SAS) URI:

On the disk's page, select Export from the menu.
Choose an expiry time for the SAS URL (1 hour or more depending on your needs).
Click on Generate URL. This generates a SAS URI for the disk, allowing temporary access to the disk file.
Copy the SAS URL:

Copy the generated SAS URL for the disk.
Export the Disk to Storage Account Using Azure Storage Explorer or AzCopy:

Using Azure Storage Explorer:

Open Azure Storage Explorer and navigate to the storage account where you want to store the disk.
Under Blob Containers, create a new container or select an existing one.
Click on Upload and select Upload blob.
Paste the SAS URL in the file source field to import the disk to the blob container.
Using AzCopy:

Download and install AzCopy if you haven’t.
Run the following command in your terminal:bash
azcopy copy "<SAS-URL>" "https://<storage_account>.blob.core.windows.net/<container_name>/<file_name>.vhd"
Replace <SAS-URL> with the copied SAS URL, <storage_account> with the name of your storage account, <container_name> with your blob container name, and <file_name> with the desired name for your exported VHD file.
Verify the Exported VHD:

Once the upload is complete, navigate to the blob container in the Azure Portal or Storage Explorer to confirm that the disk has been successfully exported as a VHD file.
This exported VHD can now be downloaded or used to create new Azure VMs or disks.
```
