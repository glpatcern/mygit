from django.conf.urls.defaults import *

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^myApps/', include('myApps.foo.urls')),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^admin/', include(admin.site.urls)),
    (r'^$', 'myTaskManager.views.index'),
    (r'^tasks/$', 'myTaskManager.views.index'),
    (r'^tasks/add$', 'myTaskManager.views.add'),
    (r'^tasks/(?P<task_id>\d+)/add_log$', 'myTaskManager.views.add_log'),
    (r'^tasks/mainform$', 'myTaskManager.views.mainform'),
    (r'^tasks/orderby/(?P<orderby>\w+)$', 'myTaskManager.views.index'),
    (r'^restaurants/$', 'myRestos.views.index'),
    (r'^restaurants/add$', 'myRestos.views.add'),
    (r'^restaurants/del_upd$', 'myRestos.views.del_upd'),
)
