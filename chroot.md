# Chroot

## Create

### Build env

```sh
mkdir -p /var/chroot && cd /var/chroot
mkdir my_os_folder

apt install debootstrap
debootstrap debian my_os_folder

mkdir -p my_os_folder/{proc,dev,sys,tmp}
chmod 1733 my_os_folder/tmp
```

### chroot and dev, proc, sys

*Posted on May 1, 2012*

chroot is a great tool to rescue systems. But a limitation is that /dev, /sys and /proc are not mounted by default but needed for many tasks. This can be done by using mount –bind on the host. Here an example how to get a functional chroot:

```
mount /dev/sda1 /mnt
cd /mnt
mount -t proc proc proc/
mount -t sysfs sys sys/
mount -o bind /dev dev/
chroot .
```
