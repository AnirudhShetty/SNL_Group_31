import pygame
from pygame import *
from pygame.locals import *
from pygame.sprite import *
from random import *
import socket
import NodeID
import re
import sys
import time

port = 8000

#if __name__ == '__main__':
class traffic(Sprite):
    def __init__(self):
        Sprite.__init__(self)
        self.image = image.load("TS.jpg")
        self.rect = self.image.get_rect()
	self.rect.center = (500, 360)
    def left(self):
        self.image = image.load("TS.jpg")
        self.rect = self.image.get_rect()
        self.rect.center = (720, 480)
    # ending background


pygame.init()
traffics = traffic()
#socket defination
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.bind(('', port))

#the window size
screen = display.set_mode((1024, 720))

#draw start background to the screen
sprites5 = Group(traffics)
sprites5.update()
sprites5.draw(screen)
display.update()

while True:
    # COnect and uncommnet line 45, 58, 61. 58,61 are added for testing
    #assuming the same message format rpt[x] should give me the value at that point
    data, addr = s.recvfrom(1024)
    #data = '32' #dummy
    if (len(data) > 0):

        rpt = NodeID.NodeID(data=data, data_length=len(data))
        """
        print "addr"
        print rpt.get_messageType()
        """
        #print rpt

    traffics.left()
    sprites5.update()
    sprites5.draw(screen)
    c = font.Font("Impact.ttf", 30)
    f = font.Font("Impact.ttf", 45)
    c = f.render("Controller ID" + str(rpt[73]), False, ((255,255,255)))
    #c = f.render("Controller ID  :  " + str(rpt.get_controllerID()), False, ((255,255,255)))#dummy
    screen.blit(c, (450, 200))
    p = f.render("Car Count" + str(rpt[91]), False, ((255,255,255)))
    #p = f.render("Car Count  :  " + str(rpt.get_car_count()), False, ((255,255,255)))#dummy
    screen.blit(p, (450, 300))
    display.update()
    time.sleep(0.5)

        #back_chod(srsr)
