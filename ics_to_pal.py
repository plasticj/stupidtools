#!/usr/bin/python

import sys,os
import icalendar

if len(sys.argv) < 2:
    print "usage: ics_to_pal.py <file1.ics> <file.pal>"
    sys.exit(1)

print "opening %s..." % sys.argv[1]
fh = open(sys.argv[1],"rb")

cal = icalendar.Calendar.from_string(fh.read())
events = [e for e in cal.walk() if type(e) == icalendar.cal.Event]

print "%u events found in %s" % (len(events), sys.argv[1])
pals = []
for e in events:
    start = e.get('dtstart').dt
    end = e.get('dtend').dt
    summary = e.get('summary')
    loc = e.get('location')
    pals.append("%s %s-%s %s, %s" % ( start.strftime("%Y%m%d"),
                            start.strftime("%H:%M"),
                            end.strftime("%H:%M"),
                            summary,
                            loc) )

oh = open(sys.argv[2],"w")
oh.write('\n'.join(pals)+'\n')
