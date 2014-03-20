# myTaskManager views 

from django.shortcuts import render_to_response, get_object_or_404
from myTaskManager.models import *
from django import forms
import datetime
from django.forms.extras.widgets import SelectDateWidget
from django.forms.models import modelformset_factory
import re

class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
    chk = forms.BooleanField(required=False)
    due_date = forms.DateField(initial=datetime.date.today()+datetime.timedelta(days=15))

def frontpage(request):
    """Front page"""
    return render_to_response('frontpage.html', dict())

def get_tasks_with_colors(orderby='insert_date'):
    tasks_list = []
    if orderby == 'insert_date': orderby = '-' + orderby
    for t in Task.objects.order_by(orderby).all():
        color = Priority.objects.get(name=t.priority).color
        t.color = color
        tasks_list.append(t)
    return tasks_list    

def index(request, orderby='insert_date'):
    """Lists all tasks"""
    tasks_list = get_tasks_with_colors(orderby)
    return render_to_response('myTaskManager/index.html', {'tasks_list' : tasks_list})

def add(request):
    """Add new task"""
    if request.method == 'POST':
        p = request.POST
        form = TaskForm(p)
        #if form.is_valid(): #need to handle the wrong values instead of doing nothing silently 
        print form.as_table()
        form.save()
        return render_to_response('myTaskManager/index.html', {'tasks_list' : get_tasks_with_colors()})
    else:
        form = TaskForm()
    return render_to_response('myTaskManager/add.html', { 'form' : form})


#def detail(request, task_id):
#    """Shows task details"""
#    print 'detail: task_id = ', task_id
#    t = get_object_or_404(Task, pk=task_id)
#    return render_to_response('myTaskManager/detail.html', {'task' : t})

def add_log(request, task_id):
    """Add new log"""
    t = Task.objects.get(pk=task_id)
    l = Log.objects.create(text=request.POST['some_text'], task_id=task_id)
    l.save()
    print 'Inside add_log: task_id =', task_id
    tasks_list = [t]
    return render_to_response('myTaskManager/detail.html', {'tasks_list' : tasks_list})

def mainform(request, task_id=None):
    """Delete/update/detail tasks"""

    if request.method == 'POST':
        
        p = request.POST

        if not task_id: pklist=p.getlist("selected")
        else: pklist = task_id
        
        if not pklist and 'Updated' not in p: return render_to_response('myTaskManager/index.html', {'tasks_list' : Task.objects.all()})

        if 'Delete' in p:
            for i in pklist:
                Task.objects.get(pk=i).delete()
                return render_to_response('myTaskManager/index.html', {'tasks_list' : get_tasks_with_colors()})

        if 'Update' in p:
            TaskFormSet = modelformset_factory(Task, extra=0)
            formset = TaskFormSet(queryset=Task.objects.filter(id__in=pklist))
            return render_to_response('myTaskManager/update.html', { 'formset' : formset})

        if 'Updated' in p:
            TaskFormSet = modelformset_factory(Task, extra=0)
            formset = TaskFormSet(p)
            #checking what has changed
            print p
            tot_forms = int(p['form-TOTAL_FORMS'])
            print 'total forms =', tot_forms
            newdata = []
            fields = ['subject', 'status', 'category', 'priority', 'person', 'id']
            for i in range(0, tot_forms): 
                print i
                a = dict()
                for field in fields:
                    key = 'form-' + str(i) + '-' + field
                    #print 'key, value=', key, p[key]
                    if field == 'status': 
                        var = Status.objects.get(pk=p[key])
                        a[field] = var.name    
                    elif field == 'priority': 
                        var = Priority.objects.get(pk=p[key])
                        a[field] = var.name    
                    elif field == 'status': 
                        var = Status.objects.get(pk=p[key])
                        a[field] = var.name    
                    elif field == 'category': 
                        var = Category.objects.get(pk=p[key])
                        a[field] = var.name    
                    elif field == 'person': 
                        var = Person.objects.get(pk=p[key])
                        a[field] = var.name    
                    else: a[field] = p[key]
                newdata.append(a)
            print 'newdata=', newdata    

            #this should go after the formset validation
                        
            if formset.is_valid():
                for i in newdata:
                    print i
                    t = Task.objects.get(pk=i['id'])
                    for field in fields:
                        if str(i[field]) != str(t.__getattribute__(field)):
                            some_text = field + ' changed from ' + str(t.__getattribute__(field)) + ' to ' + str(i[field])
                            l = Log.objects.create(text=some_text, task_id=i['id'])
                            l.save()
                formset.save()
            else: 
                print 'mainform: updated block: formset not vaild!'
            return render_to_response('myTaskManager/index.html', {'tasks_list' : get_tasks_with_colors()})

        if 'Details' in p:
            print 'Inside Details'
            tasks_list = Task.objects.filter(id__in=pklist)
            return render_to_response('myTaskManager/detail.html', {'tasks_list' : tasks_list})
            
