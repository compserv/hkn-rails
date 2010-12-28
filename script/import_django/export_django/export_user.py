#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from django.contrib.auth.models import User

def main():
  export(User, 'user', filter=lambda user: not user.username.startswith('imported__'))

if __name__ == '__main__':
  main()
