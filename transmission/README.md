# Transmission

Transmission is a bit-torrent client; in one of its version, there is a 
daemon with CLI and web interface, which are useful for us since we do 
not even have a display and we are forced to connect to the Pi remotely.

## Installation

Install the package `transmission-cli` and start the daemon with `sudo 
systemctl start transmission.service`. You can also enable the service. 
The daemon is managed by the user "transmission". Create then a 
directory accessible both by you and the daemon where to save downloads. 
If this directory lies in a removable device, add 
`RequiresMountsFor=/path/to/dir` to 
`/etc/systemd/system/transmission.service.d/transmission.conf` in the 
section [Unit]. You may need to create this file.

## Web interface

We configured transmission in order that the web interface was 
accessible from a computer in the same LAN as the Pi. First, we inserted 
value `"127.0.0.*,192.168.*.*"` for option `rpc-whitelist`. Then we 
added the server hostname, `"raspi"`, for option `rpc-host-whitelist`.
