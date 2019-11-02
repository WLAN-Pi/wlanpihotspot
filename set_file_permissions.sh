#! /bin/bash
#
# Set file ownership & permissions correctly when copying files from Win machine 
sudo chown -R root:root /etc/wlanpihotspot
sudo chmod -R 744 /etc/wlanpihotspot

sudo chmod 644 /etc/wlanpihotspot/default/ufw
sudo chmod 644 /etc/wlanpihotspot/sysctl/sysctl.conf
sudo chmod 640 /etc/wlanpihotspot/ufw/before.rules

