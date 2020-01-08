#for get uuid of camera
import time, os, subprocess
from subprocess import *
import re

a=subprocess.Popen('tail -n 500 /usr/local/nginx/logs/access.log'.split(),stdout=PIPE)
#time.sleep(8)
camera_list = []
while True:

        #a.terminate()
        line = a.stdout.readline()
        line = line[60::]
        items = re.findall('frames',line)
#       print items
        if items:
		line = line.split(" ")
                line = line[0]
                camera_list.append(line)
        if not line:
                break
#       print ">>>>"
camera_number = set(camera_list)
print len(camera_number)
