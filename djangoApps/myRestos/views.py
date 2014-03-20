# myRestos views

from django.shortcuts import render_to_response, get_object_or_404
from myRestos.models import Restaurant
from django import forms
from django.forms.models import modelformset_factory

class RestaurantForm(forms.ModelForm):
    class Meta:
        model = Restaurant
    chk = forms.BooleanField(required=False)

def index(request):
    """List of restaurants"""
    restos_list = Restaurant.objects.all()
    return render_to_response('myRestos/index.html', {'restos_list' : restos_list})

def add(request):
    """Add new restaurant"""
    if request.method == 'POST':
        p = request.POST
        form = RestaurantForm(p)
        form.save()
        return render_to_response('myRestos/index.html', {'restos_list' : Restaurant.objects.all()})
    else:
        form = RestaurantForm()
    return render_to_response('myRestos/add.html', { 'form' : form})


def del_upd(request, resto_id=None):
    """Delete/update restaurant record(s)"""
    
    print 'request.method = ', request.method
    print request.POST
    p = request.POST

    if request.method == 'POST':
        if not resto_id: pklist=p.getlist("selected")
        else: pklist = resto_id
        
        if not pklist and 'Updated' not in p: return render_to_response('myRestos/index.html', {'restos_list' : Restaurant.objects.all()})

        if 'Delete' in p:
            for i in pklist:
                Restaurant.objects.get(pk=i).delete()
            return render_to_response('myRestos/index.html', {'restos_list' : Restaurant.objects.all()})

        if 'Update' in p:
            RestaurantFormSet = modelformset_factory(Restaurant, extra=0)
            formset = RestaurantFormSet(queryset=Restaurant.objects.filter(id__in=pklist))
            return render_to_response('myRestos/update.html', { 'formset' : formset})

        if 'Updated' in p:
            RestaurantFormSet = modelformset_factory(Restaurant, extra=0)
            formset = RestaurantFormSet(p)
            formset.save()
            return render_to_response('myRestos/index.html', {'restos_list' : Restaurant.objects.all()})

            
            
            
