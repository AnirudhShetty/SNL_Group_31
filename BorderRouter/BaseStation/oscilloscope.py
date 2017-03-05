#!/usr/bin/env python

import sys
#import serial
from tinyos import tos

AM_OSCILLOSCOPE = 0x93

class OscilloscopeMsg(tos.Packet):
    def __init__(self, packet = None):
        tos.Packet.__init__(self,
                            [('version',  'int', 2),
                             ('interval', 'int', 2),
                             ('id',       'int', 2),
                             ('count',    'int', 2),
                             ('readings', 'blob', None)],
                            packet)
if '-h' in sys.argv:
    print "Usage:", sys.argv[0], "serial@/dev/ttyUSB0:57600"
    sys.exit()

am = tos.AM()
pm = tos.AM()
#ser = serial.Serial('/dev/ttyUSB0', 115200)
#print(ser.name)
#x = ser.read()
#print(x)
#s = ser.read(10)
#print(s)
#line = ser.readline(100)
#print(line)

while True:
    p = am.read()
    p1 = pm.read()
    if p and p.type == AM_OSCILLOSCOPE:
	msg = OscilloscopeMsg(p.data)
        msg1 = OscilloscopeMsg(p1.data)
        
        #print msg.id, msg.count, [i<<8 | j for (i,j) in zip(msg.readings[::2], msg.readings[1::2])]

        if msg1.readings[1] > msg.readings[1]:
		print msg.id,msg.count,msg.readings[1],msg1.id,msg1.count,msg1.readings[1], "MsgSmall"
	else:
		print msg.id,msg.count,msg.readings[1],msg1.id,msg1.count,msg1.readings[1], "M1Small"
     

        
        


