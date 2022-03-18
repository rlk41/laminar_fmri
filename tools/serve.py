#!/usr/bin/env python


import tornado.ioloop
import tornado.web
import json
import os


# # class HomeHandler(tornado.web.RequestHandler):
# #     def get(self):
# #         self.render('index.html')

# # # class MatchHandler(tornado.web.RequestHandler):
# # #     def get(self):
# # #         self.write(json.dumps(games))

# # path = os.path.join(os.getcwd(), 'app')
# # if __name__ == "__main__":
# #     application = tornado.web.Application(
# #         [
# #             (r'/', HomeHandler),
# #             (r'/games', MatchHandler),
# #             (r'/*.*', tornado.web.StaticFileHandler, {'path': path})
# #         ],
# #         template_path=os.path.join(os.path.dirname(__file__), 'app')
# #     )
# #     application.listen(16001)
# #     tornado.ioloop.IOLoop.current().start()

# class MainHandler(tornado.web.RequestHandler):
#     def get(self):
#         self.write("Hello, world")



import tornado.ioloop
import tornado.web

#path = os.path.join(os.getcwd(), 'app')


class HomeHandler(tornado.web.RequestHandler):
    def get(self):
        self.render('/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca5/mean/plots.html')

if __name__ == "__main__":
    application = tornado.web.Application([
        (r"/", HomeHandler),
    ])
    #        (r'/*.*', tornado.web.StaticFileHandler, {'path': path})


    application.listen(8888)
    tornado.ioloop.IOLoop.current().start()


#"/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca5/mean/plots.html"
#"/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_ave/mean/plots.html"
#"/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/mean/plots.html"