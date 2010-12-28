#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from hkn.info.models import Person

def main():
  export(Person, 'person')

if __name__ == '__main__':
  main()
