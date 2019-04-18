# Web server

We will write here how we configured a LAMP server.

## PHP

Install *php*. Set the default timezone in `/etc/php/php.ini` and enable 
extensions `pdo_mysql`, `mysqli`, `bz2` and `zip`.

## Apache

Install package *apache*, then start and enable the httpd.service. 
Install *php-apache*, then edit `/etc/httpd/conf/httpd.conf` commenting 
the line `#LoadModule mpm_event_module modules/mod_mpm_event.so` and 
uncommenting `LoadModule mpm_prefork_module modules/mod_mpm_prefork.so`. 
Also, at the end of the `LoadModule` list add 

```
LoadModule php7_module modules/libphp7.so
AddHandler php7-script .php
```

and at the end of the `Include` list add

```
Include conf/extra/php7_module.conf
```

You can also set the webmaster email address, as we did.

## MariaDB

Install *mariadb*, then run the command `# mysql_install_db --user=mysql 
--basedir=/usr --datadir=/var/lib/mysql`. After that, you can start and 
enable mariadb.service. Then, run `# mysql_secure_installation`. Now 
edit `/etc/mysql/my.cnf` and uncomment `skip-networking`. Append the 
following lines:

```
[client]
default-character-set = utf8mb4

[mysqld]
collation_server = utf8mb4_unicode_ci
character_set_server = utf8mb4

[mysql]
default-character-set = utf8mb4
```

Finally, populate the time zone tables with the command `$ 
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql`

We turn off binary logging, since we do not need it, by commenting 
`#log-bin=mysql-bin` and `#binlog_format=mixed` in `/etc/mysql/my.cnf`. 
Also, to purge existing binary logs, run `# mysql -u root -p"password" 
-e "PURGE BINARY LOGS TO 'mysql-bin.0000xx';"`.

## phpMyAdmin

phpMyAdmin is a front end for mariadb. Install *phpmyadmin* and follow 
[this guide](https://wiki.archlinux.org/index.php/PhpMyAdmin).

To enable advanced features, follow the link "To find out why...", which 
will lead you to the creation of the *phpmyadmin* database.

## Firewall

On the router administration page, look for NAT and add an appropriate 
rule. Also, `# modprobe ip_tables` to enable the firewall on the 
machine.


## Extras

### Virtual hosts

Often it is useful to host many sites on a single server. First of all, 
we will create a directory for each site, in this case we `mkdir 
/srv/http/domain1`. (or `mkdir /home/user/domain1`, but in this case 
make sure that the path is accessible to the http user.) Inside those 
directories you can put your site (html pages, php scripts...).

Next, we create a directory `/etc/httpd/conf/vhosts`, where we will put 
the configuration files for the hosts; we decided to have one config 
file per host. Inside that directory, we create as many files as we want 
virtual hosts. We will use the default virtual host configuration as 
template, so we will copy `/etc/httpd/conf/extra/httpd-vhosts.conf` to 
`/etc/httpd/conf/vhosts/domain1.conf` (it is the same for domain2, 
domain3, and so on). Then, edit each vhost configuration file according 
to your necessities.

Finally, we have to include our configuration files into the main apache 
configuration file, therefore we edit `/etc/httpd/conf/httpd.conf`, 
adding the following lines:

```
# Enable virtual hosts
Include conf/vhosts/domain1.conf
Include conf/vhosts/domain2.conf
```

One line for each configuration file. Now you can easily enable/disable 
your hosts by uncommenting/commenting the corresponding line in 
`/etc/httpd/conf/httpd.conf`.

Moreover, since the directory `/srv/http` will only contain the other 
site, we can spare our server from serving it: comment out the line 
`DocumentRoot "/srv/http"` and all the `<Directory "/srv/http/"> 
section.

If you will try to reach the server with its IP address, you will get 
the first virtual host you have included (in this case domain1).

### Dynamic DNS

The fact that our internet service provider (IPS) offers us a dynamic IP 
address means that the IP will change every so often, making it 
difficoult to reach the server. Therefore, we exploited a dynamic DNS 
provider that gives us a free domain name that is associated to our IP. 
There are many providers among which to choose, for instance 
[no-ip](https://www.noip.com/), [dynu](https://www.dynu.com/en-US/) or 
[DNS 
dynamic](https://www.dnsdynamic.org/validate.php?q=2b7194fd48c3ddcfd7b3aff65b9ca8d85a916719ddfcc).

If the domain does not work, chances are that there is one of the 
following two problems: either the domain name servers have not been 
updated yet, and this will solve in a matter of hours (at most); or you 
are trying to reach the hostname with a secure connection (check whether 
on the url bar there is http or https), but your server is not 
configured for such connections.

### SSL/TLS

We also enabled secure encrypted connections. First, we obtained a 
dynamic dns (see section above), then we generated a self-signed 
certificate with the command:

```
# cd /etc/httpd/conf
# openssl req -new -x509 -nodes -newkey rsa:4096 -keyout server.key -out server.crt -days 1
```

This certificate is temporary: we only need it in order for things to 
work. Without it, our website will not be accessible. This command will 
generate the files server.key and server.crt in /etc/httpd/conf, 
representing the key and the certificate, respectively.

In order to enable ssl support (and rewrite, which is needed), we 
uncommented the following lines in `/etc/httpd/httpd.conf`:

```
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
Include conf/extra/httpd-ssl.conf
```

At this point, we had to edit the default 
`/etc/httpd/conf/extra/httpd-ssl.conf`, commenting out the entire 
"<VirtualHost>" section; we then added a <VirtualHost> section to our 
`/etc/httpd/conf/vhosts/domain1.conf`, copying the directives from the 
section we commented and adapting them according to our needs; in 
particular, we will use the self signed certificates we have just 
created. It is important to set as NameServer the domain given by your 
dynamic dns provider.

Next, run

```
pacman -S certbot-apache
certbot --apache certonly
```

Certbot asks some simple questions (including the nameservers for which 
you want a certificate; that is why it is important to specify the 
nameserver in the configuration file), then challenges the server, and if 
everything works fine, it gives you your certificates. Certbot is the 
official client of Let's Encrypt, which is a Certificate Authority (CA). 
Briefly, a CA is an authorised certificate provider. Operating systems, 
web browsers, and so on, cannot afford to trust anybody to be who they 
say, so they only trust a set of certificate, i.e. those provided by 
CAs. CAs, then, have the task to verify that the owner of a certificate 
is who they claim to be. There are many kinds of certificates, but to 
know what Let's Encrypt offers, see [this 
page](https://letsencrypt.org/how-it-works/).

Note that you can use a certificate for how many nameservers as you 
like, just make sure that you have all the virtual hosts correctly 
configured.

If you did things right, you should see the following output from 
certbot:

> IMPORTANT NOTES:
> - Congratulations! Your certificate and chain have been saved at:
>   /etc/letsencrypt/live/domain1/fullchain.pem
>   Your key file has been saved at:
>   /etc/letsencrypt/live/domain1/privkey.pem
>   Your cert will expire on XXXX-XX-XX. To obtain a new or tweaked
>   version of this certificate in the future, simply run certbot
>   again. To non-interactively renew *all* of your certificates, run
>   "certbot renew"
> - If you like Certbot, please consider supporting our work by:
>
>   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
>   Donating to EFF:                    https://eff.org/donate-le

Now, we need to tell our server to use the new Let's Encrypt certificate 
instead of the self-signed one, editing again the configuration file of 
our virtual host domain1. As always, restart httpd.service, then connect 
to your server and check if everything works. If it does, you can remove 
the self-signed cert and key.

You can check at any time your certificates with the command `certbot 
certificates`.

Let's Encrypt has some nice features:

* it is free and automated;

* its certificates expire in 90 days.

Much as the second feature is nice, it also means that you almost always 
want to automate the renewal process. A systemd unit with its coupled 
timer is precisely what we need. We provide the files inside this 
directory, which will automatically renew all certificates on every 
thursday at 02:00:00; if you want to use them, link them to 
`/etc/systemd/system/`, then start and enable certbot.timer.

For further information, you can refer to 
[this](https://certbot.eff.org/#arch-apache) and 
[this](https://certbot.eff.org/docs/using.html#where-are-my-certificates) 
pages.
