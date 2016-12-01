#!/usr/bin/env python
# stolen from Arsh
import itertools
import os

def generate_list(lang,max_len):
	words = []
	for length in range(1,max_len+1):
		perms = itertools.product(lang,repeat=length)
		for word in perms:
			password = ''.join(word)
			words.append(password)
	return words

if __name__ == '__main__':
	words = generate_list("abcd",3)
	#words = generate_list("abcdefghijklmnopqrstuvwxyz",7)
	with open('passwords.txt','w') as password_file:
		for word in words:
			password_file.write(word+os.linesep)
	print ("Done")