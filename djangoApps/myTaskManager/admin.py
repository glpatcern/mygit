from myTaskManager.models import Category, Status, Person, Task, Priority, Log
from django.contrib import admin

admin.site.register(Category)
admin.site.register(Status)
admin.site.register(Person)
admin.site.register(Priority)
admin.site.register(Log)

class TaskAdmin(admin.ModelAdmin):
    list_display = ('subject', 'insert_date', 'due_date', 'status', 'person', 'category', 'priority')
    list_filter = ['insert_date', 'status', 'category', 'priority']
    search_fields = ['subject', 'log']

admin.site.register(Task, TaskAdmin)
 
