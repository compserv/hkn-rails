#!/usr/bin/env python

# Make sure you run this as root!

from export_table import export
from hkn.info.models import Position

def main():
  export(Position, 'position')

if __name__ == '__main__':
  main()
