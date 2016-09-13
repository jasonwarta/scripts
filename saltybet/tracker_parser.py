#!/usr/bin/env python

from enum import Enum
from pymongo import MongoClient
import select
import socket
import time
import random

class State(Enum):
	OPEN=1
	WINS=2

def available(conn):
	try:
		readable,writeable,errored=select.select([conn],[],[],0)
		if conn in readable:
			return True
	except:
		pass
	return False

def starts_with(in_str,match):
	return (match in in_str and in_str.index(match)==0)

if __name__=='__main__':
	sock=None
	nick="justinfan"
	state=State.OPEN
	team1=''
	team2=''
	winner=''
	line=''

	random.seed();
 	nRand = random.randint(1000000000000,9999999999999)

	while True:
		try:
			sock=socket.socket()
			sock.connect(("irc.chat.twitch.tv",6667))
			sock.send('NICK '+nick+str(nRand)+'\r\n')
			sock.send('JOIN #saltybet\r\n')

			client=MongoClient()
			db=client.saltybet

			while True:
				if available(sock):
					buff=sock.recv(1024)

					if not buff:
						raise Exception("Disconnect")
					for ii in range(len(buff)):
						line+=buff[ii]

						if line[-2:]=='\r\n':
							line=line.rstrip()
							ping='PING :tmi.twitch.tv'
							pong='PONG :tmi.twitch.tv\r\n'
							waifu=':waifu4u!waifu4u@waifu4u.tmi.twitch.tv PRIVMSG #saltybet :'

							if starts_with(line,ping):
								sock.send(pong)
							elif starts_with(line,waifu_match):
								line=line[len(waifu_match):]
								#print(line)
								# with open('log','a') as fstr:
								# 	fstr.write(line+"\n")

								if state == State.OPEN:
									if "OPEN" in line:
										state=State.WINS
										# parse out player/team names
										team1=line[(line.find("for ")+4):(line.find(" vs "))]
										team2=line[(line.find(" vs ")+4):(line.find("! ("))]
										print("Team1: '" + team1 + "', Team2: '" + team2 + "'")
										# add data to mongodb
										db.names.update(
												{ 'name': team1 },
												{ '$inc': { 'games': 1 } },
												upsert=True
											)
										db.names.update(
												{ 'name': team2 },
												{ '$inc': { 'games': 1 } },
												upsert=True
											)

								if state == State.WINS:
									if "wins" in line:
										state=State.OPEN
										# parse out winner name
										winner=line[:line.find(" wins!")]
										print("Winner: '" + winner + "'")
										# add data to mongodb
										db.names.update(
												{ 'name': winner },
												{ '$inc': { 'wins': 1 } },
												upsert=True
											)
							line=''