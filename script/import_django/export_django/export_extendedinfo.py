#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from hkn.info.models import ExtendedInfo

def main():
  export(ExtendedInfo, 'extendedinfo')

if __name__ == '__main__':
  main()
