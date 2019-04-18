# User management

We will describe here methods to add, remove and modify users in the 
system.

When we first log in to the Raspberry, there are quite a few users 
already, used by the system to organise its processes and files. One of 
these users is root, but there is also a mail user, an ftp user, and so 
on. There is then another user, alarm, which is intended to be used 
routinely by a non-administrator user. We would rather have accounts 
with the names we choose, so we will edit the alarm account and create a 
new one. We do not simply delete alarm -- it would bee too easy.

## Changing a user

The commands needed are usermod and optionally groupmod; rely on [this 
guide](https://wiki.archlinux.org/index.php/Users_and_groups).

## Adding a user

Use **useradd**.
