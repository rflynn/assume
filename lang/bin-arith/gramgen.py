#!/usr/bin/python

def isterm(g, key):
  return key in g

def match(g, m, i, max):
  if 0 == max:
    return 0
  elif 1 == max:
    
  
def doit(cnt):
  grammar = {
    'val' : [ ['0'], ['1'], ['val'] ],
    'op'  : [ ['+'], ['-'] ],
    'expr': [ ['val'], ['op','val'], ['expr','op','expr'] ]
  }
  m = [{'index':0}] * cnt

