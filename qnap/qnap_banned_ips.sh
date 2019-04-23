/opt/bin/sqlite3 /mnt/HDA_ROOT/.logs/notice.log "select count(*) from naslog_notice where desc = 'admin Login Fail (SSH)' and time > strftime('%s', 'now') - $1*86400;"
