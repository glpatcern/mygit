from django.db import models

# Create your models here.

class Person(models.Model):

    name = models.CharField(max_length=20)
    email = models.CharField(max_length=50)

    def __unicode__(self):
        return self.name

class Category(models.Model):

    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

class Status(models.Model):

    name = models.CharField(max_length=20)

    def __unicode__(self):
        return self.name

class Priority(models.Model):

    name = models.CharField(max_length=20)
    color = models.CharField(max_length=20)

    def __unicode__(self):
        return self.name

class Log(models.Model):

    text = models.TextField(blank=True)
    task = models.ForeignKey('Task')
    time = models.DateTimeField(auto_now=True)

    def __unicode__(self):
        return self.text


class Task(models.Model):

    subject = models.CharField(max_length=200)
    insert_date = models.DateField('Insertion date', auto_now_add=True)
    due_date = models.DateField('Due date', null=True, blank=True)
    category = models.ForeignKey(Category)
    person = models.ForeignKey(Person, null=True, blank=True)
    status = models.ForeignKey(Status)
    priority = models.ForeignKey(Priority)

    def __unicode__(self):
        return self.subject


    
