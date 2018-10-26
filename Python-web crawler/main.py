#This is the base file where project name and homepage and queue file and crawled file will be initialied

import threading
from queue import Queue
from spider import Spider
from domain import *
from general import *

PROJECT_NAME = 'BBC'
HP = 'http://www.bbc.com/'  #Homepage
DOMAIN_NAME = get_domain_name(HP)
qf = PROJECT_NAME + '/queue.txt' #Queue file
cf = PROJECT_NAME + '/crawled.txt' #Crawled file
NUMBER_OF_THREADS = 6
queue = Queue()
Spider(PROJECT_NAME, HP, DOMAIN_NAME)

