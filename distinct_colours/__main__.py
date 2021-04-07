# This file is part of viscm
# Copyright (C) 2015 Nathaniel Smith <njs@pobox.com>
# Copyright (C) 2015 Stefan van der Walt <stefanv@berkeley.edu>
# See file LICENSE.txt for license information.

import sys
from distinct_colours import gui


def main():
  gui.main(sys.argv[1:])

if __name__ == '__main__':
  main()
