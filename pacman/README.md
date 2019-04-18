# Pacman

Pacman is Arch's excellent package manager. One of its most useful 
features is that instead of overwriting the configuration files you 
edited, it creates a .pacnew file containing the updated version of the 
configuration file, and leaves to you the choice about what to do.
Another interesting feature of this software is that it allows you to 
create custom hooks.

## Add some colour

Edit `/etc/pacman.conf` and uncomment the appropriate option.

## Hooks

### Clean cache

Pacman does not automatically remove old versions of packages, so after 
a while the cache can become quite large, especially if you only have 16 
GB in your SD card... We therefore created a hook to clean the cache 
every time we run pacman, following [this 
post](https://bbs.archlinux.org/viewtopic.php?pid=1694743). The hook is 
designed to keep only the most recent of old versions, and remove the 
others. If you want to use it, just create the directory 
`/etc/pacman.d/hooks` and put the file `clean_cache.hook` that you find 
in this directory.

### List (possibly) residual files

```
$ find /etc /opt /usr | sort > all_files.txt
$ pacman -Qlq | sed 's|/$||' | sort > owned_files.txt
$ comm -23 all_files.txt owned_files.txt
```

However, this produces a lot of files, most of which are useful. We plan 
to create a list of authorised files by running this command at the 
beginning, when everything is still candid, then comparing the list at 
time X with the list at X0.
