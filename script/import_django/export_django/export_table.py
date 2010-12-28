# Necessary setup for interfacing with Django
import sys, os, datetime
sys.path.append('/var/www/hkn')
sys.path.append('/var/www/hkn/django-common')
from django.core.management import setup_environ
from django.core.exceptions import ObjectDoesNotExist
import django
import settings
import nice_types
setup_environ(settings)

# Python 2.5 doesn't support json yet..., so import simplejson
import simplejson

def export(klass, filename, export_dir='dumps', filter=lambda x: True):
  objects = {}
  for object in klass.objects.all():
    if filter(object):
      objects[object.pk] = object.__dict__

  # By default, convert datetime objects to RfC 3339 strings
  semhandler = lambda obj: str(obj) if isinstance(obj, nice_types.semester.Semester) else None
  dthandler = lambda obj: obj.isoformat() if isinstance(obj, datetime.datetime) else semhandler(obj)

  if not os.path.isdir(export_dir):
    os.mkdir(export_dir)
  f = open('%s/%s.json' % (export_dir, filename), 'w')
  simplejson.dump(objects, f, default=dthandler)
  f.close()
