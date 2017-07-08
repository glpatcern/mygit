#!/bin/sh
#
# autorun.sh - executed at startup by QNAP
#
############################################

# set ssh tunnelling and sshd users
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
#sed -i 's/AllowUsers admin/AllowUsers admin glp/' /etc/ssh/sshd_config

# keep monitoring and refreshing the home-assistant configuration
~admin/qnap/hass/refreshconfig.sh &

# public RSA key
rm -rf /etc/config/ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6xys2NBv//wVaLvxxG7h9ckwD/AmyEEBOcGfFZmtgBciLtIhSkDrJ58RxozcZGDUZ/Sd3VLvylYSOfkKXxUbgxZthq8JgjBrSJ/0k4LyrjYV55LHYCl/+Q6LbLm24guOz2cUgqunthijKXvbvBpiNpv/yXqJdMqOC7dvD/IA+RJ2FIfQ6ub1gquqwVmSet1HDxQRjGFwYIWlMCrQVXpREJ0YRX9/dINIvpEIoQNF8MPYwhmK2GBrVQkGwY6B4zUvHFMWRgiul8Fe4phoJxKcq83JkdOu/UkwKIXvxPa5wKV2K18vDmgGn4mEUUWrQXJ5Y+c9PiTchju4ddMVPVl1x lopresti@pcitdss04' > /etc/config/ssh/authorized_keys

# change shell to zsh
usermod --shell /share/CACHEDEV1_DATA/.qpkg/Entware-ng/bin/zsh admin &> /dev/null

# useful symbolic links
for s in ~admin/qnap/*sh; do ln -s -f $s /usr/local/bin; done
ln -s /share/CACHEDEV1_DATA/.qpkg/Python3/python3 /usr/local/bin
ln -s /opt/sbin/mosquitto /usr/local/sbin

# zsh specific configuration
cat > ~glp/.zshrc << EOF
# path for qnapware utils and other stuff
export PATH=$PATH:/Apps/sbin:/opt/bin:/Apps/opt/sbin:/usr/local/mariadb/bin:/share/CACHEDEV1_DATA/.qpkg/JRE/jre/bin:/share/CACHEDEV1_DATA/.qpkg/Python3/python3/bin:/share/CACHEDEV1_DATA/.qpkg/container-station/bin
export PYTHONPATH=/share/CACHEDEV1_DATA/.qpkg/Python3/python3/lib/python3.5/site-packages

# prompt
export PROMPT=$'%{\e[32m%}%n%{\e[37m%}@%{\e[33m%}%m%{\e[37m%}:%{\e[36m%}%3/%{\e[0m%}> '
export RPROMPT=$'%{\e[1;34m%}%D{%b %d}, %T%{\e[0m%}'

# aliases
alias ll='/bin/ls -laFh'
alias nmapscan='nmap -sS -v -Pn -O'
EOF

cp ~glp/.zshrc /root

# useful links
ln -s /share/CACHEDEV1_DATA/.qpkg /root/QTS
ln -s ~glp/QSync/qnap /root/qnap
ln -s ~glp/QSync/dev/DOMOTICA /root/DOMOTICA
ln -s /share/Container/homeass-config /root
ln -s /share/COntainer/homeass-config/home-assistant.log /var/log

