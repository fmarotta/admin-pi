# SSH Tunnel

## Basics

On a remote server which is not accessible from the internet, but can 
access the internet, run the following command:

```
ssh -nNT -pXX -R ZZ:server:YY user@raspi
```

where server is the name of the remote server, raspi is the URL of your 
raspberry, and user is your username on the raspberry. Note that ports 
XX and ZZ must be open, and the remote server must listen to ssh 
connections on port YY (change port numbers according to your needs).

Then, log in to raspi, and from there run:

```
ssh -p ZZ localhost
```

You will be redirected to the remote server.

## Users management

Since many people wanted to use my tunnel, I had to create an account 
for each of them. The setup is as follows.

Only the first time, create a file */path/to/config* with the following 
contents:

```
Host server
	HostName localhost
	Port ZZ
```

Then, for each new user that wants to use the tunnel,

1. Create a user with no personal group and no home directory.

```
useradd -N user -d /etc/ssh/user
```

2. Add an entry in */etc/ssh/sshd_config*

```
Match User user
	#AuthorizedKeysFile /path/to/authorized_keys
	Include /path/to/config
	ForceCommand ssh server
	#PermitEmptyPasswords yes
```

3. If the user gives you a public key, put it in 
   */path/to/authorized_keys* and uncomment #AuthorizedKeysFile, 
otherwise uncomment #PermitEmptyPasswords
