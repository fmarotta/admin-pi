# Backup

To get an idea of how much backing up your system is important, take a 
look at [this](http://www.backup.info/quotes).

## Our custom solution

We wrote a simple shell script to perform the backup and some systemd 
units to automatically run the script; link the script to your 
`/usr/local/bin`, so that it will be in your PATH. In order not to enter 
the password when backing up databases, we created the file 
`/root/.my.cnf` containing the username and password to connect to the 
databases. See 
http://stackoverflow.com/questions/9293042/how-to-perform-a-mysqldump-without-a-password-prompt

## Notes

We had to include `/var/lib/private` to our rsyncignore list. This 
directory appears to be a private directory created by timedatectl. See 
[here](https://wiki.archlinux.org/index.php/Systemd-timesyncd).
