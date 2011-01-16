#!/usr/bin/env python

# Make sure you run this as root!

import sys
from export_table import export
sys.path.append('/var/www/hkn')
sys.path.append('/var/www/hkn/django-common')
import django.contrib.auth.models
import hkn.info.models

def main():
  export(django.contrib.auth.models.User, 'user', filter=lambda user: not user.username.startswith('imported__'))
  export(django.contrib.auth.models.Permission, 'permission')
  export(hkn.info.models.Person, 'person')
  export(hkn.info.models.ExtendedInfo, 'extendedinfo')
  export(hkn.info.models.Officership, 'officership')
  export(hkn.info.models.Position, 'position')
  export(hkn.event.models.Event, 'event')
  export(hkn.event.models.RSVP, 'rsvp')

if __name__ == '__main__':
  main()
