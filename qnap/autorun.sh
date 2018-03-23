#!/bin/sh
#
# autorun.sh - executed at startup by QNAP
#
############################################

# set ssh tunnelling and sshd users
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
echo >> /etc/ssh/sshd_config
echo 'PermitOpen any' >> /etc/ssh/sshd_config
#sed -i 's/AllowUsers admin/AllowUsers admin glp/' /etc/ssh/sshd_config

# keep monitoring and refreshing the home-assistant configuration
~admin/qnap/hass/refreshconfig.sh &

# public RSA key
rm -rf /etc/config/ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6xys2NBv//wVaLvxxG7h9ckwD/AmyEEBOcGfFZmtgBciLtIhSkDrJ58RxozcZGDUZ/Sd3VLvylYSOfkKXxUbgxZthq8JgjBrSJ/0k4LyrjYV55LHYCl/+Q6LbLm24guOz2cUgqunthijKXvbvBpiNpv/yXqJdMqOC7dvD/IA+RJ2FIfQ6ub1gquqwVmSet1HDxQRjGFwYIWlMCrQVXpREJ0YRX9/dINIvpEIoQNF8MPYwhmK2GBrVQkGwY6B4zUvHFMWRgiul8Fe4phoJxKcq83JkdOu/UkwKIXvxPa5wKV2K18vDmgGn4mEUUWrQXJ5Y+c9PiTchju4ddMVPVl1x lopresti@pcitdss04' > /etc/config/ssh/authorized_keys

# change shell to zsh
usermod --shell /share/CACHEDEV1_DATA/.qpkg/Entware-ng/bin/zsh admin &> /dev/null

# useful links to tools
for s in ~admin/qnap/*sh; do ln -s -f $s /usr/local/bin; done
ln -s /share/CACHEDEV1_DATA/.qpkg/Python3/python3 /usr/local/bin
ln -s /opt/sbin/mosquitto /usr/local/sbin

# zsh and tmux specific configurations
cp ~glp/.zshrc /root
cp ~glp/.tmux.conf /root

# useful links to common directories
ln -s /share/CACHEDEV1_DATA/.qpkg /root/QTS
ln -s /share/CACHEDEV1_DATA/Web /root/Web
ln -s ~glp/QSync/qnap /root/qnap
ln -s ~glp/QSync/dev/DOMOTICA /root/DOMOTICA
ln -s /share/Container/homeass-config /root
ln -s /share/Container/homeass-config/home-assistant.log /var/log
