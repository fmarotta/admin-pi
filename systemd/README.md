# Systemd

## Locale

Use the command **timedatectl set-timezone <time/zone>** to set the 
local timezone; for instance, replace <time/zone> with Europe/Rome.

## Journal size

Place the drop-in file from this directory to your  
`/etc/systemd/journald.conf.d/` to set a 300MB limit to the journal 
size.
