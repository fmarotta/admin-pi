#!/bin/sh

# This is a workaround to avoid the following error message:
# raspi [9069]: failed to execute '/usr/bin/hciconfig' '/usr/bin/hciconfig hci0:11 up': No such file or directory

# hciconfig has been deprecated by bluez, but some packages trick another into
# thinking that it should be running...

# Since everything works fine, we can safely hide the error message, replacing
# it with a notice. This is a only a dirty workaround because we do not have
# time/will to further investigate the matter.

systemd-cat -p 5 echo "NOTICE: hciconfig has been deprecated. This is a \
workaround script by fmarotta that warns you that something is wrong."
