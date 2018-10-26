#spider is the library in python used for indexing the files from queue file to transfer it them to crawled(indexed) files.
from urllib.request import urlopen
from link_finder import LinkFinder
from domain import *
from general import *


class Spider:

#using of spider library
#initialize the variables to null
    pn = ''  #project name
    base_url = ''
    domain_name = ''
    qf = ''
    crf = ''
    queue = set()
    crawled = set()

    def __init__(self, pn, base_url, domain_name):
        Spider.pn = pn
        Spider.base_url = base_url
        Spider.domain_name = domain_name
        Spider.qf = Spider.pn + '/queue.txt'
        Spider.crf = Spider.pn + '/crawled.txt'
        self.boot()
        self.crawl_page('First spider', Spider.base_url)

    # Creates directory and files for project on first run and starts the spider
    @staticmethod
    def boot():
        create_project_dir(Spider.pn)
        create_data_files(Spider.pn, Spider.base_url)
        Spider.queue = file_to_set(Spider.qf)
        Spider.crawled = file_to_set(Spider.crf)

    # Updates user display, fills queue and updates files
    @staticmethod
    def crawl_page(thread_name, page_url):
        if page_url not in Spider.crawled:
            print(thread_name + ' now crawling ' + page_url)
            print('Queue ' + str(len(Spider.queue)) + ' | Crawled  ' + str(len(Spider.crawled)))
            Spider.add_links_to_queue(Spider.gather_links(page_url))
            Spider.queue.remove(page_url)
            Spider.crawled.add(page_url)
            Spider.update_files()

    #Method to convert response data from the project file into readable data and also checks the html formatting
    @staticmethod
    def gather_links(page_url):
        html_string = ''
        try:
            response = urlopen(page_url)
            if 'text/html' in response.getheader('Content-Type'):
                html_bytes = response.read()
                html_string = html_bytes.decode("utf-8")
            finder = LinkFinder(Spider.base_url, page_url)
            finder.feed(html_string)
        except Exception as e:
            print(str(e))
            return set()
        return finder.page_links()


    #static method to save queue data to project files
    @staticmethod
    def add_links_to_queue(links):
        for url in links:
            if (url in Spider.queue) or (url in Spider.crawled):
                continue
            if Spider.domain_name != get_domain_name(url):
                continue
            Spider.queue.add(url)

    @staticmethod
    def update_files():
        set_to_file(Spider.queue, Spider.qf)
        set_to_file(Spider.crawled, Spider.crf)
