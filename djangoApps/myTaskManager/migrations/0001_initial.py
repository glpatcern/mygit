# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):
    
    def forwards(self, orm):
        
        # Adding model 'Person'
        db.create_table('myTaskManager_person', (
            ('email', self.gf('django.db.models.fields.CharField')(max_length=50)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=20)),
        ))
        db.send_create_signal('myTaskManager', ['Person'])

        # Adding model 'Category'
        db.create_table('myTaskManager_category', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=200)),
        ))
        db.send_create_signal('myTaskManager', ['Category'])

        # Adding model 'Status'
        db.create_table('myTaskManager_status', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=20)),
        ))
        db.send_create_signal('myTaskManager', ['Status'])

        # Adding model 'Task'
        db.create_table('myTaskManager_task', (
            ('category', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['myTaskManager.Category'])),
            ('due_date', self.gf('django.db.models.fields.DateTimeField')()),
            ('log', self.gf('django.db.models.fields.CharField')(max_length=5000, blank=True)),
            ('person', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['myTaskManager.Person'])),
            ('status', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['myTaskManager.Status'])),
            ('subject', self.gf('django.db.models.fields.CharField')(max_length=200)),
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('insert_date', self.gf('django.db.models.fields.DateTimeField')()),
        ))
        db.send_create_signal('myTaskManager', ['Task'])
    
    
    def backwards(self, orm):
        
        # Deleting model 'Person'
        db.delete_table('myTaskManager_person')

        # Deleting model 'Category'
        db.delete_table('myTaskManager_category')

        # Deleting model 'Status'
        db.delete_table('myTaskManager_status')

        # Deleting model 'Task'
        db.delete_table('myTaskManager_task')
    
    
    models = {
        'myTaskManager.category': {
            'Meta': {'object_name': 'Category'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        },
        'myTaskManager.person': {
            'Meta': {'object_name': 'Person'},
            'email': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '20'})
        },
        'myTaskManager.status': {
            'Meta': {'object_name': 'Status'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '20'})
        },
        'myTaskManager.task': {
            'Meta': {'object_name': 'Task'},
            'category': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['myTaskManager.Category']"}),
            'due_date': ('django.db.models.fields.DateTimeField', [], {}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'insert_date': ('django.db.models.fields.DateTimeField', [], {}),
            'log': ('django.db.models.fields.CharField', [], {'max_length': '5000', 'blank': 'True'}),
            'person': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['myTaskManager.Person']"}),
            'status': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['myTaskManager.Status']"}),
            'subject': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        }
    }
    
    complete_apps = ['myTaskManager']
