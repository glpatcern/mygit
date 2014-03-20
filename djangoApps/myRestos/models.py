from django.db import models

class Restaurant(models.Model):
    name = models.CharField(max_length=200)
    address = models.CharField(max_length=4000)
    phonenumber = models.CharField(max_length=50, blank=True, null=True)
    email = models.EmailField(blank=True, null=True)

    def __unicode__(self):
        return self.name

