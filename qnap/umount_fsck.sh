# Stop everything, unmount and check the data disks
#
# Giuseppe Lo Presti, October 2015
####################################################

# stop all services
/etc/init.d/services.sh stop
/etc/init.d/opentftp.sh stop
/etc/init.d/Qthttpd.sh stop
#/share/CACHEDEV1_DATA/.qpkg/SurveillanceStation/qpkg_surveillances.sh stop
killall wdd
killall _thttpd_
kill `ps aux | grep php | grep master | awk '{print $1}'`
echo
echo Waiting for the filesystem to settle down...
sleep 6

# attempt to unmount: this works if the script is NOT on disk...
umount /dev/mapper/cachedev1
if [ $? != 0 ]; then
  echo
  echo "Can't unmount data disks now, lsof shows the following files are open:"
  lsof /dev/mapper/cachedev1
  echo
  echo Please kill the remaining processes and try again
else
  echo Data disks successfully unmounted. Checking...
  # check
  /bin/e2fsck_64 -f -v -C 0 /dev/mapper/cachedev1 
  echo
  echo To remount:
  echo mount /dev/mapper/cachedev1 -t ext4 /share/CACHEDEV1_DATA
fi
echo
