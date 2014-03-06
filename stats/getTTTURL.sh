zgrep 'TURL available' $1 | grep -v SRMDaemon | awk '{print $NF}' | cut -d= -f 2 | sort | uniq -c | sort -k 2 -n
