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
