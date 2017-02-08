#!/bin/python
from BaseHTTPServer import BaseHTTPRequestHandler
from SocketServer import TCPServer, ThreadingMixIn
from Queue import Queue
import threading, socket

# contributed from http://code.activestate.com/recipes/574454-thread-pool-mixin-class-for-use-with-socketservert
class ThreadPoolMixIn(ThreadingMixIn):
    '''Use a thread pool instead of a new thread on every request'''
    numThreads = 10
    allow_reuse_address = True  # seems to fix socket.error on server restart

    def serve_forever(self):
        '''
        Handle one request at a time until doomsday.
        '''
        # set up the threadpool
        self.requests = Queue(self.numThreads)
        for x in range(self.numThreads):
            t = threading.Thread(target = self.process_request_thread)
            t.setDaemon(1)
            t.start()
        # server main loop
        while True:
            self.handle_request()
        self.server_close()
    
    def process_request_thread(self):
        '''obtain request from queue instead of directly from server socket'''
        while True:
            ThreadingMixIn.process_request_thread(self, *self.requests.get())
    
    def handle_request(self):
        '''simply collect requests and put them on the queue for the workers'''
        try:
            request, client_address = self.get_request()
        except socket.error:
            return
        if self.verify_request(request, client_address):
            self.requests.put((request, client_address))

class ThreadPoolServer(ThreadPoolMixIn, TCPServer):
    '''A thread-pool-based TCP server'''
    pass


class TestHttpRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.wfile.write('My GET response')

    def do_POST(self):
        self.wfile.write('My POST response')

def run():
	TestHttpRequestHandler.protocol_version = 'HTTP/1.0'
	httpd = ThreadPoolServer(('', 8080), TestHttpRequestHandler)
	sa = httpd.socket.getsockname()
	print "Serving HTTP on", sa[0], "port", sa[1], "..."
	httpd.serve_forever()

run()

