#!/usr/bin/env python3
import sys
import socket
import string
import random

HOST = "irc.chat.twitch.tv"
PORT = 6667

NICK="justinfan"

random.seed();
nRand = random.randint(1000000000000,9999999999999)

s=socket.socket()
s.connect((HOST,PORT))

# s.send(bytes("PASS"))
s.send(bytes("NICK %s%s\r\n" % (NICK,str(nRand)),"UTF-8"))

msg = s.recv(4096)
print(msg)

s.send(bytes("JOIN #saltybet\r\n","UTF-8"));

msg = s.recv(4096)
print(msg)

while 1:
    readbuffer=s.recv(1024).decode("UTF-8")

    lines=readbuffer.split('\r\n')
    if len(lines)>0:
        if len(readbuffer)<2 or readbuffer[:-2]!='\r\n':
            readbuffer=lines[-1]
        lines.pop()

    match=':waifu4u!waifu4u@waifu4u.tmi.twitch.tv PRIVMSG #saltybet :'
    ping='PING :tmi.twitch.tv'
    for line in lines:
        if match in line and line.index(match)==0:
        		# print(line[len(match):])
        		with open('chatlog.txt','a') as fstr:
        				fstr.write(line[len(match):] + "\n")
        if ping in line and line.index(match)==0:
        		s.send(bytes("PONG :tmi.twitch.tv","UTF-8"))
        print(line)
