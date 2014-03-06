#!/usr/bin/python
import sys, datetime, math

def usage(code):
    print sys.argv[0] + ' <srmfed log file>'
    sys.exit(code)

if len(sys.argv) != 2:
    usage(1)
logfile = open(sys.argv[1])

def secs(td):
  return (td.microseconds + (td.seconds + td.days * 24.0 * 3600) * 10**6) / 10**6

d = {}
errors = []

while(True):
    l = logfile.readline()
    if l == '':
        break
    if l.find('ExitStatus=')<0:continue
    opts = dict([x.split('=') for x in l[56:].split(' ') if x.find('=')>=0])
    endtime = datetime.datetime.strptime(l[0:26], "%Y-%m-%dT%H:%M:%S.%f")
    tid = opts['TID']
    if opts['Message'] == '"Too':
        errors.append((endtime, tid))
    secs, microsecs = opts['ProcessingTime'].split('.')
    td = datetime.timedelta(0,int(secs),int(microsecs))
    starttime = endtime - td
    typ = opts['RequestType']
    #print endtime, secs, microsecs, starttime, typ
    if tid not in d:d[tid] = []
    d[tid].append((starttime, endtime, td, typ))

for t, tid in errors:
    print tid, 'Error at ' + str(t) + '. Activity of other threads :'
    for tid in d:
        first = True
        for s,e,dur,typ in d[tid]:
            if e < t:
                first = False
                continue
            if s < t:
                print '  ', tid, ':', typ, 'from', s, 'to', e, 'for', dur
            elif not first:
                print ' N', tid, ':', typ, 'from', s, 'to', e, 'for', dur
            break
