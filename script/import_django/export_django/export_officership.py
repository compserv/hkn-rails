#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from hkn.info.models import Officership

def main():
  export(Officership, 'officership')

if __name__ == '__main__':
  main()
