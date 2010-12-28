#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from hkn.event.models import Event

def main():
  export(Event, 'event')

if __name__ == '__main__':
  main()
