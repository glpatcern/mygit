from django.conf.urls.defaults import *

urlpatterns = patterns('myTaskManager.views',
    (r'^tasks/$', 'index'),
    (r'^/tasks/(?P<task_id>\d+)/add_log$', 'add_log'),
)
