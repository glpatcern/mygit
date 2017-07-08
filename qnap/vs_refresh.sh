#!/bin/sh

SHARE_CONF=/etc/rsyncd.conf
VOLUME_CONF=/etc/config/volumeStatus.conf

# Traverse all shares and update settings.
/bin/sed -n 's/\[\(.*\)\]/\1/p' $SHARE_CONF | while read SHARE
do
	FILES=$(( $(/usr/bin/find "/share/${SHARE}/" -type f | /usr/bin/wc -l) + 0 ))
	DIRS=$(( $(/usr/bin/find "/share/${SHARE}/" -type d | /usr/bin/wc -l) - 1 ))
	SIZE=$(/usr/bin/du -scB1 "/share/${SHARE}/" | /usr/bin/tail -1 | /bin/cut -f1)

	/sbin/setcfg "$SHARE" "Used Size" $SIZE -f $VOLUME_CONF
	/sbin/setcfg "$SHARE" "Directory Count" $DIRS -f $VOLUME_CONF
	/sbin/setcfg "$SHARE" "File Count" $FILES -f $VOLUME_CONF
done 
