for l in `seq 12 72`; do zgrep '' log.$l.gz | awk '{print $13}'; done | sort | uniq -c
