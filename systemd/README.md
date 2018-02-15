# Systemd

## Locale

Use the command **timedatectl set-timezone <time/zone>** to set the 
local timezone; for instance, replace <time/zone> with Europe/Rome.

## Journal size

Place the drop-in file from this directory to your  
`/etc/systemd/journald.conf.d/` to set a 300MB limit to the journal 
size.

## Systemd User Units

If you want your user units to start at boot, you have to add the option 
`WantedBy=default.target`, not multi-user.target, because in systemd 
user space there is no such target. See 
[here](https://unix.stackexchange.com/questions/251211/why-doesnt-my-systemd-user-unit-start-at-boot).

One useful thing, especially in headless devices, where you are not 
constantly logged in while the machine is up and running, is the 
lingerig feature, that allows to run user units at boot, without the 
user to be actually logged in. See [here] for further information; to 
enable it, run `# loginctl enable-linger <user>`.
