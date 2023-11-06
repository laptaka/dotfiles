#!/bin/bash

yay -S --needed --noconfirm epson-inkjet-printer-escpr epson-printer-utility

sudo systemctl enable --now ecbd.service
# Replace line hosts: mymachines in /etc/nsswitch.conf with hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns
sudo sed -i '/hosts: mymachines/c\hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns' /etc/nsswitch.conf
