zgrep 'New Req' $1 | grep srmfed | awk '{print $10}' | sort | uniq -c
