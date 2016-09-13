#!/usr/bin/env python

from enum import Enum
from pymongo import MongoClient

class State(Enum):
	OPEN=1
	WINS=2
	DONE=3
	EOF=4

with open('log') as log:
	state=State.OPEN
	team1=''
	team2=''
	winner=''

	client=MongoClient()
	db=client.saltybet

	while (state != State.EOF):
		line=log.readline()

		if line == '':
			state=State.EOF
		
		if state == State.OPEN:
			if "OPEN" in line:
				state=State.WINS
				team1=line[(line.find("for ")+4):(line.find(" vs "))]
				team2=line[(line.find(" vs ")+4):(line.find("! ("))]
				print("Team1: '" + team1 + "', Team2: '" + team2 + "'")
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
				winner=line[:line.find(" wins!")]
				print("Winner: '" + winner + "'")
				db.names.update(
						{ 'name': winner },
						{ '$inc': { 'wins': 1 } },
						upsert=True
					)
