#!/usr/bin/python

import os
import sys

# usage function
def usage():
  print "Usage:", sys.argv[0], "classname package methods"
  print "  classname : name of the new class"
  print "  methods   : file containing all methods' signatures."
  sys.exit(0)
  
# Get a single text line
def getline():
  global currentLine
  currentLine = methods.readline()
  if currentLine == '':
    raise ValueError, 'EOF'

## main()

# first parse options
if (len(sys.argv) != 4):
  usage()

package = sys.argv[2]
if package == '':
  package = 'castor::'
if not package.endswith(':'):
  package += '::'
methods = open(sys.argv[3], 'r')
clname = sys.argv[1]

# open templates
srcpath = sys.argv[0]
srcpath = srcpath[:srcpath.rfind('/')]
hpp = open(srcpath + '/Skeleton.hpp', 'r').read()
cpp = open(srcpath + '/Skeleton.cpp', 'r').read()
hpp = hpp.replace('Skeleton', clname).replace('SKELETON', clname.upper())
cpp = cpp.replace('Skeleton', clname)
counter = 0
hppskel = ''

try:
  while(1):
    getline()
    retval = currentLine[:currentLine.find('  ')]
    method = currentLine[currentLine.find('  ')+2:currentLine.find('(')]
    cppskel='''
//------------------------------------------------------------------------------
// ''' + method + '''
//------------------------------------------------------------------------------
'''
    method += currentLine[currentLine.find('('):].strip('\n')
    hppskel += '    /// \n    ' + retval +' '+ method +';\n\n'
    if retval.startswith('virtual'):
      retval = retval[8:]
    cppskel += retval +' '+ package + clname +'::'+ method +' {\n}\n'
    cpp += cppskel
    counter += 1

except ValueError:
  # terminate here
  f = open(clname + '.hpp', 'w')
  f.write(hpp.replace('METHODS', hppskel.strip('\n')))
  f.close()
  f = open(clname + '.cpp', 'w')
  f.write(cpp)
  f.close()
  print "\nSkeleton generation complete,", counter, "methods created."

