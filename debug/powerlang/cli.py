# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contains GDB CLI commands and convenience variables/functions
"""

import re

import gdb

from itertools import chain

from powerlang.printing import obj
from powerlang.objectmemory import segments

flatten = chain.from_iterable


class __DumpObjectCmd(gdb.Command):
    """
    Dump contents or expression EXP
    Usage: do EXP [EXP...]

    An expression EXP can be either OOP as numerical constant
    (for example '0x1ff10028') or C/C++ expression which is 
    evaluated in current frame (for example, 'kernel->header.module')
    """
    def invoke (self, args, from_tty):
        self(*gdb.string_to_argv(args))

    def __call__(self, *exprs):
        for expr in exprs:
            self.dump(expr)

    def complete(self, text, word):
        return gdb.COMPLETE_EXPRESSION

    def dump(self, expr):
        o = None
        try:
            o = obj(expr)
        except:
            print("Failed to evaluate '%s'" % expr)
            return

        print(str(o))
        if not o.isBytes():
            for name, value in o.children():
                pp = gdb.default_visualizer(value)
                if pp == None:
                    print("    %-15s:  %s" % ( name , value ))
                else:
                    print("    %-15s:  %s" % ( name , pp.to_string() ))


do = __DumpObjectCmd('do', gdb.COMMAND_DATA)

class __LookupMethod(gdb.Command):
    """
    Looks up a method containing given PC or matching given REGEXP.
    Usage: lm [PC]
           lm REGEXP
    
    PC can be given as an expression evaluating to an address
    or omitted in which case value if $pc (PC of currently 
    selected frame) is used. 

    If REGEXP is given, all methods whose name matches
    given regexp are looked up and printed.
    """
    def invoke(self, args, from_tty):
        argv = gdb.string_to_argv(args)
        if len(argv) > 1:
            raise Exception("lm takes only one argument (%d given)" % len(argv))
        elif len(argv) == 0:
            argv = ['$pc']    
        for method in self(argv[0]):
            print(method)

    def __call__(self, pc_or_regexp = '$pc'):
        pc = None
        regexp = None
        try:
            pc = None
            if isinstance(pc_or_regexp, int):
                pc = pc_or_regexp
            else:
                pc = gdb.parse_and_eval(pc_or_regexp)
        except:
            regexp = re.compile(pc_or_regexp)

        symtabs = (segment.symtab for segment in segments)

        if pc != None:    
            for symtab in symtabs:
                sym = symtab.lookup_symbol_by_addr(pc)
                if sym != None:
                    return [sym.method]
            return []
        if regexp != None:
            return (sym.method for sym in flatten(symtabs) if regexp.search(sym.name))

lm = __LookupMethod('lm', gdb.COMMAND_DATA)


