# NFS

Network File System is a protocol allowing to access files in a 
different computer (server) from a local computer (client), as though 
the files were on a file system mounted locally.

## Server

Install *nfs-utils* and create the directory which will be shared, for 
instance `/srv/nfs/music`. If your music is in a removable hard drive, 
say `/mnt/music`, you can `# mount --bind /mnt/music /srv/nfs/music` so 
that now the shared directory will mirror /mnt/music.

Edit `/etc/exports` so that it will look somewhat like this:

```
/srv/nfs	192.168.1.0/24(rw,sync,no_subtree_check,fsid=0,crossmnt)
/srv/nfs/music	192.168.1.0/24(rw,sync,no_subtree_check)
```

Then, start and enable nfs-server.service.

## Client

Install nfs and simply mount the file system. You can add an entry to 
/etc/fstab to simplify your line.
