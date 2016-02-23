#!/usr/bin/python2.7

#
# this little python script takes a list of commands as parameter
# and then looks for the necessary linked libraries for it to run
# (incl. all softlinks etc)
#

import re
import subprocess
import sys
import os


# get all commands from the command line
commands=[]
for arg in sys.argv[1:]:
  commands.append(arg)

# now get all the linked libraries
libraries = {}
for c in commands:
  libraries[c] = []
  # first parse the output of ldd
  # and cut out all the listed libraries
  try:
    for l in subprocess.check_output(['ldd', c]).splitlines():
      # check if the output looks something like
      #     libtinfo.so.5 => /lib64/libtinfo.so.5 (0x00007f75cb196000)
      match = re.match(r'\t.* => (.*) \(0x', l)
      if match:
        # before we add the library to the dict
        # we will extend the real path of the directory (no links)
        libraries[c].append(
          os.path.join(
            os.path.realpath(os.path.dirname(match.group(1))),
            os.path.basename(match.group(1))
          )
        )
      match = re.match(r'\t(\/lib.*?ld-linux-.*?) \(0x', l)
      if match:
        # check if the output looks something like
        #     /lib64/ld-linux-x86-64.so.2 (0x000055b869507000)
        libraries[c].append(
          os.path.join(
            os.path.realpath(os.path.dirname(match.group(1))),
            os.path.basename(match.group(1))
          )
        )
    # now run trough all the registered libraries and
    # check if they are a symbolic link or not
    for l in libraries[c]:
      if os.path.islink(l):
        # if it is a link extend the list with the full path
        libraries[c].append(os.path.realpath(l))
  except subprocess.CalledProcessError:
    # this is raised either if the binary c was not found
    # or if the binary is not a dynamically linked binary
    continue

# at the end of the day our little bash cleanup script only 
# needs to know which libraries it should keep.
# we therefore write all libraries to stdout (the binaries are
# from no interest)
output = []
for key,libs in libraries.iteritems():
  for l in libs:
    output.append(l)
# sort list and remove duplicates
output = sorted(set(output))

for l in output:
  print l