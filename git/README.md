# Git

Git is a version control system which is very useful to track your work. 
In this section we will write about how to install, configure and use 
it.

## Intallation & configuration

On Arch Linux, simply install the `git` package, then let the program 
know your name, email and preferences issuing the following commands, as 
described [here](https://wiki.archlinux.org/index.php/Git).

```
$ git config --global user.name  "John Doe"
$ git config --global user.email "johndoe@example.com"
$ git config --global diff.tool vimdiff
$ git config --global alias.graph "log --graph --oneline --decorate"
```

Also, we added some useful bash aliases:

```
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gck='git checkout'
alias gda='git diff --minimal'
alias gdb='git branch -d'
alias gdc='git diff --cached --minimal'
alias gnb='git checkout -b'
alias gr='git remote -v'
alias gs='git status'
```

## Usage

TODO.

## Setting up a git server

*git* is great when it comes to version control, so we should like to 
use it for our documents (thesis, articles, reports...). Setting up a 
git server will allow us to:

* Host **private** remote repositories on our raspberry;

* Have a backup copy of our work accessible from the internet;

* Work from everywhere, then push and pull from the remote;

* Easily collaborate on the same documents.

For this set up we will follow [this 
guide](https://git-scm.com/book/en/v1/Git-on-the-Server). 

### Server configuration

In order for others to collaborate with us in our projects, we will 
exploit the git user which was automatically added to the system during 
git installation. Let us give a home to our git user:

```
# usermod -m -d /srv/git git
```

If that directory is not automatically created, do it yourself and chown 
it to git:git. Also,

```
# mkdir /srv/git/.ssh
```

Now, to simplify our lives at a cost in security, we could allow the git 
user to use scp. By default, it runs a special shell, "git-shell", as 
you can see from `/etc/passwd`, which can only run selected commands. To 
add a custom command, we create the directory `git-shell-commands` in 
git's home directory, and make a symbolic link from `/usr/bin/scp` to 
`/srv/git/git-shell-commands/scp`. We do not think it is a good idea, 
though.

If we don't add the commands we want to run as git, we will get a
`fatal: unrecognized command 'scp -r -t /srv/git/prject.git'`.

Some say that in order for things to work, you should `chmod -R go= 
/srv/git/.ssh` to allow ssh-related files to be shared, but we did not 
do it and everything works anyway.

### Local configuration

Each of the users who want access to the remote git server must generate 
an ssh-key on their local machines as described in the ssh directory of 
this repository; they may like to call the file 
`~/.ssh/id_ed25519_git_raspi`, where "raspi" is the name of our server.

Next, the public key from the local machine is to be manually added to 
`/srv/git/.ssh/authorized_keys` on the server.

Finally, the user has to edit his/her ~/.ssh/config as described in the 
ssh directory of this repository. Make sure that the port used to 
connect to the ssh server is right, and that the user is "git".

Note that these are the same steps required to use ssh-keys with, say, 
github. For our server, we chose to allow access over ssh only, for 
security reasons, so these steps are mandatory. Note also that, since 
the git user cannot really log in to the server, the user must edit 
his/her `~/.ssh/config` so that the access will always be performed with 
the keys. (Otherwise, a password prompt will start, but the git user has 
no password because it cannot log in...)

### Server usage

Let us start from the point where you have a local repository and you 
want to host it on your remote server (the raspberry pi). First of all, 
you have to generate a bare repository from the existing one. A bare 
repository, which by convention ends in ".git", is simply the content of 
the project's `.git` directory, without all the extra files, because 
they are not needed. So, on the local machine,

`git clone --bare project project.git`

Now you have to manually move the bare repository to your server. Ask 
the system administrator to do so for you. (You can always allow git 
user to use scp or another custom command, as described in the previous 
section.)

Note that the user will have access to the git account on the server 
because he/she will have generated an ssh-key and added it to 
/srv/git/.ssh/authorized_keys, as dercribed in a previous section, but 
he/she will now be able to login because the git user is not allowed to.

Now, the user will need to add the remote repository:

```
git remote add origin ssh://git@server:22/srv/git/project.git
```

In the previous command, "22" is the ssh port (change it according to 
your ssh configuration), and "ssh://" [may be 
necessary](https://stackoverflow.com/questions/3596260/git-remote-add-with-other-ssh-port).

### Conclusions

With this setup:

1. a user generates a pair of ssh-key and gives the public one to the 
   sever administrator;

2. the server administrator decides if the user is trusted and whether 
   he/she will have read and write access to the directory `/srv/git` 
for his/her git projects; if the user is trusted, the admin adds his/her 
key to `/srv/git/.ssh/authorized_keys`;

3. when the user wants to upload his/her project to the server, he/she 
   gives the .git bare repository to the server administrator, who, if 
willing, copies it to `/srv/git/project.git`;

4. from that moment on, the user can add the bare repository as remote 
   repository for his/her project, and push or pull accordingly.

We now allow access through ssh keys only. In the future, however, 
things are likely to change. Ideally, we would like to have some private 
repositories, some shared ones and some public ones; shared repositories 
are accessible by a small number of users, whereas public ones are open 
to everyone who knows the url. Also, it would be interesting to 
configure some repositories to be RO and others to be RW.
