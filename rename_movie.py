#!/usr/bin/env python

# import requests
import requests,json,sys
from sys import stdout, exit
from os import listdir, rename, _exit
from os.path import isfile, join

reload(sys)  
sys.setdefaultencoding('utf8')

def query_yes_no(question,default='yes'):
	valid={'yes':True,'ye':True,'y':True,
		   'no':False,'n':False,}
	if default is None:
		prompt=" [y/n] "
	elif default == 'yes':
		prompt=" [Y/n] "
	elif default == 'no':
		prompt=" [y/N] "
	else:
		raise ValueError("invalid default answer: '%s'" % default)
	
	while True:
		stdout.write(question+prompt)
		choice=raw_input().lower()
		if default is not None and choice == '':
			return valid[default]
		elif choice in valid:
			return valid[choice]
		else:
			stdout.write("Please respond with 'yes' or 'no' "
							 "(or 'y' or 'n'.\n")

def getData( title ):
	url="http://www.omdbapi.com/?t="+title.replace(' ','+')+"&r=json"
	r=requests.get(url)
	parsed_data=json.loads(r.text)
	return parsed_data

def main():
	mypath="./"
	badwords=['BRRip','BrRip','DVDRip','Dvdrip','720p','1080p','1080','BluRay','iPod','Unrated','UNRATED','Webrip','DVD']

	files = [f for f in listdir(mypath) if isfile(join(mypath,f))]
	files.sort();

	for f in files:
		print ('-----------------------------------------------------------')

		file=f
		file=file.replace('.',' ')
		file=file.replace('_',' ')
		file=file.replace('(',' ')
		file=file.replace(')',' ')
		file=file.replace('-',' ')
		file=file.replace('[',' ')
		file=file.replace(']',' ')
		file=file.replace(':',' ')
		file=file[:-4]
		
		for w in badwords:
			if w in file:
				file=file[:file.index(w)]

		# print file

		data=getData(file)

		if data['Response'] == "False":
			dupfile=file
			while data['Response'] == "False":
				try:
					dupfile=dupfile[:dupfile.rindex(' ')]
					# print "Trying: "+dupfile 
					data=getData(dupfile)
				except ValueError:
					break

		if data['Response'] == "True":
			fname=data['Title']+" ("+data['Year']+")"+f[f.rindex('.'):]
			fname=fname.replace('/','-')
			if fname != f:
				print (f+"  -->  "+fname)
				if query_yes_no('Rename?','yes'):
					rename(f,fname)
					print ("Renamed "+f+" to "+fname)
				else:
					print ("Did not rename "+f)
			else:
				print (f+" was already named correctly")
		else:
			print ("Couldn't get data for "+f)


if __name__ == '__main__':
	try:
		main()
	except KeyboardInterrupt:
		print ('Interrupted')
		try:
			exit(0)
		except SystemExit:
			_exit(0)


