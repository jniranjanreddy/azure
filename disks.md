## Disk can be expanded online

```

Once disk is expanded in Azure portal

growpart /dev/sdc 1

root@dev-cd-vm:~# xfs_growfs /dev/sdc1
meta-data=/dev/sdc1              isize=512    agcount=4, agsize=4194240 blks
         =                       sectsz=4096  attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=0 inobtcount=0
data     =                       bsize=4096   blocks=16776960, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=8191, version=2
         =                       sectsz=4096  sunit=1 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 16776960 to 33554171

FStab Entries
root@dev-cd--vm:~# cat /etc/fstab
# CLOUD_IMG: This file was created/modified by the Cloud Image build process
UUID=d4004e88-d528-486d-b994-90c70f9322d4       /        ext4   discard,errors=remount-ro       0 1
UUID=D659-5A9F  /boot/efi       vfat    umask=0077      0 1
tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec 0 0
/dev/disk/cloud/azure_resource-part1    /mnt    auto    defaults,nofail,x-systemd.requires=cloud-init.service,_netdev,comment=cloudconfig       0       2
UUID=3414d5a7-31bd-45d1-b2b9-14f8309a2 /milvus-data   xfs defaults,nofail   0   0

```
## Mount a disk in othet VM
```
[root@dev-milvis ~]# mount  /dev/sdd1 /airflowVMDISK
mount: /airflowVMDISK: wrong fs type, bad option, bad superblock on /dev/sdd1, missing codepage or helper program, or other error.

mount -t xfs -o nouuid,rw /dev/sdd1 /airflowVMDISK

clean up the space,

if you want to reset the password,
sudo mount --bind /dev /tmp/othervmdisk/dev
sudo mount --bind /proc /tmp/othervmdisk/proc
sudo mount --bind /sys /tmp/othervmdisk/sys
sudo chroot /tmp/othervmdisk


to unmount
sudo umount /tmp/othervmdisk/dev
sudo umount /tmp/othervmdisk/proc
sudo umount /tmp/othervmdisk/sys
sudo umount /tmp/othervmdisk



```
