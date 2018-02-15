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
rule.
