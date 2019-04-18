# SSH

SSH, or Secure SHell, is both a network protocol and a piece of software 
based upon that protocol. (Actually, in modern Linux distributions, the 
software is called OpenSSH to emphasise that it is an open source 
version of the original SSH, but we will refer to it simply as SSH.) 
With SSH you can connect from one computer to antother exchanging 
encrypted messages; the authentication is performed through public-key 
cryptography. The first computer, the one where you are physically 
logged in, is referred to as the client, whereas the computer to which 
you connect is the server. On the server, there is a daemon that always 
listens for incoming connections; on the client, you use a software to 
connect to the daemon on the server. Read [Arch Wiki's 
page](https://wiki.archlinux.org/index.php/Secure_Shell) about SSH if 
you want to understand how it works. Here, we will describe what we did 
to tweak our SSH installation.

Some sections describing one particular aspect follow, but now we would 
like to give an overall view of SSH. You normally use it to log in to 
different computers (servers); you log in as a particular user of the 
server, so by default you are required to enter the password of the user 
you want to log in with. However, there is another option: you can 
authenticate using SSH keys, so that instead of sending the user's 
password over the network, you only send some keys. If you encrypt your 
private key, which is strongly recommended, you are prompted to enter 
the encryption password instead of the user's password. Nevertheless, 
you could use an SSH agent to remember the decrypted keys, so that you 
only have to enter the password once. If you connect to many servers, 
you could want to use different options for each of them; you can 
configure these options editing `~/.ssh/config`. Finally, you can 
configure the SSH daemon running on the server to tweak it to your 
needs. Each section below focuses on one of the aspects described here.

## Client configuration

### ~/.ssh/config

Configuring the way the SSH client -- the software you use to connect to 
the daemon on the other side -- works is straightforward: just add the 
options you want to the file `~/.ssh/config`. You can add a different 
set of options for every host.

A simple configuration could be

```
Host raspi
	IdentityFile ~/.ssh/id_ed25519_raspi
	User jon
	Port 6642
```

### Key generation

When connecting to a server, you can either enter the password of the 
user you are connecting to in the server, or use SSH keys. The latter 
method is recommended, because you do not have to send your password 
over the network, but at most you have to enter the password to decript 
the key, which then is used for the authentication. See 
[here](https://wiki.archlinux.org/index.php/SSH_keys) for a guide.

What we did was to generate the keys on our clients using 
**ssh-keygen**, then copy them on the server using **ssh-copy-id**. We 
then added a few lines to our client configuration files. Each step is 
carried out while remaining on the client. The template for the 
ssh-keygen command we normally use is:

`ssh-keygen -t ed25519 -C "<user_client>@<host_client> for <user_server>@<host_server>" -o`

and save the keys in files called something like 
`~/.ssh/id_ed25519_server`

### Agents

If you use SSH keys to authenticate to a server, you have to enter a 
password to decrypt the key every time you use it. An SSH agent caches 
the decrypted key, so that you only have to enter the password once for 
every log in session. We use ssh-agent, the default one, as our personal 
"keyring". To ensure that only one instance of the agent is running at a 
time, copy this to your bashrc:

```
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh/ssh-agent
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh/ssh-agent)"
fi
```

Then, when you want the agent to remember the password of a key for you, 
jush issue **ssh-add /path/to/key** and enter the password.

## Server configuration

This section is devoted to the modifications we did to the daemon (the 
SSH instance running on the server).

### Root login through SSH

By default you cannot log in as root through SSH, but sometimes, if you 
know what you are doing, you want to do that. In such cases, you have to 
edit the file `/etc/ssh/sshd_config`, and change 
`#PermitRootLogin prohibit-password`  
to  
`PermitRootLogin yes`  

Then restart the daemon with **systemctl restart sshd.service**, log out 
and log back in as root. When you are done with what you wanted to do, 
we recommend you revert to the default value of this option in order to 
increase security.

## Miscellaneous

### Using SSH keys with github

The steps are always the same: generate a pair of keys on the client 
with **ssh-keygen**, then add the public one to your account in github. 
You can also add the key to your agent, as described above.
