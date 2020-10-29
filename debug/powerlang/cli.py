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

def _lookup_symbol(pc_or_regexp):
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
                return [sym]
        return []
    if regexp != None:
        return (sym for sym in flatten(symtabs) if regexp.search(sym.name))


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
        return (sym.method for sym in _lookup_symbol(pc_or_regexp))
        
lm = __LookupMethod('lm', gdb.COMMAND_DATA)

class __DisassembleMethod(gdb.Command):
    """
    Disassemble a method with given PC or matching given REGEXP.
    Usage: lm [PC]
           lm REGEXP
    
    PC can be given as an expression evaluating to an address
    or omitted in which case value if $pc (PC of currently 
    selected frame) is used. 

    If REGEXP is given then method matching that REGEXP is
    disassembled
    """
    def invoke(self, args, from_tty):        
        argv = gdb.string_to_argv(args)
        if len(argv) > 1:
            raise Exception("lm takes only one argument (%d given)" % len(argv))
        elif len(argv) == 0:
            argv = ['$pc']    
        self(argv[0])

    def __call__(self, pc_or_regexp = '$pc'):          
        methodsyms = list(_lookup_symbol(pc_or_regexp))        
        if len(methodsyms) == 0:
            print("No method matching %s" % pc_or_regexp)
        elif len(methodsyms) > 1: 
            print("Multiple methods matching %s:" % pc_or_regexp)
            for methodsym in methodsyms:
                print(methodsym)
            print("Please disambiguate")
        else:
            self.disassemble(methodsyms[0])


    def disassemble(self, methodsym):
        arch = gdb.selected_inferior().architecture()
        loPC = methodsym.address
        hiPC = loPC + methodsym.size

        print(methodsym)
        for insn in arch.disassemble(loPC, hiPC - 1):            
            print("  0x%016x: %s" % ( insn['addr'], insn['asm'] ));            


am = __DisassembleMethod('am', gdb.COMMAND_DATA)