#!/usr/bin/python
#
# Typical usage: grep 'New Req' anysyslog.log | calcTimeIntervals.py | cut -c7-9 | sort | uniq -c
#
import sys, datetime, math;

def secs(td):
  return (td.microseconds + (td.seconds + td.days * 24.0 * 3600) * 10**6) / 10**6

l = sys.stdin.readline()
sq = 0
s = 0
d1 = datetime.datetime.strptime(l[0:26], "%Y-%m-%dT%H:%M:%S.%f")
d0 = d1
c = 0
while(True):
  l = sys.stdin.readline()
  if l == '':
    break
  d2 = datetime.datetime.strptime(l[0:26], "%Y-%m-%dT%H:%M:%S.%f")
  #print d2-d1
  td = secs(d2-d1)
  if td < 60:
    sq += td*td
    s += td
    c += 1
#  elif td > 60:
#    print d2, td
  d1 = d2
avg = s/c
stddev = math.sqrt(sq/c - avg*avg)
print "avg = %.4f, stddev = %.4f" % (avg, stddev)