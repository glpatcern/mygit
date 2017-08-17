#!/bin/sh
#
# refreshconfig.sh
#
# monitors the (QSync-enabled) homeass folder for changes and:
# - replicates them to the home assistant config dir
# - restarts the homeass container
#
# Giuseppe Lo Presti, July 2017
###############################################################

PATH=/share/CACHEDEV1_DATA/.qpkg/container-station/bin:$PATH
while true; do
  inotifywait --event modify ~glp/QSync/dev/DOMOTICA/homeass/*yaml
  cp ~glp/QSync/dev/DOMOTICA/homeass/*yaml /share/Container/homeass-config
  cp ~glp/QSync/dev/DOMOTICA/homeass/automations/* /share/Container/homeass-config/automations
  # if running, restart the container to reflect the change
  id=`docker ps | grep homeass | awk '{print $1}'` && \
    docker restart $id
done

