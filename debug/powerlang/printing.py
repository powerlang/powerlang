# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contain pretty-printers for GDB
"""

import re
import gdb

from itertools import chain
from gdb.printing import PrettyPrinter, SubPrettyPrinter, register_pretty_printer

from powerlang.objectmemory import Object, SmallInteger, obj
from powerlang.constants import CompiledMethodFlags

FMTxPTR = "0x%016x"
def PRIxPTR(value):
    return FMTxPTR % int(value)

def _ObjectPrintString(obj):
    if obj.isSmallInteger():
        return (FMTxPTR + " ( SmallInteger, %d " + FMTxPTR + ")") % (obj._oop, int(obj), int(obj))
    elif obj.isNil():
        return (FMTxPTR + " ( nil )") % (obj._oop)
    else:
        try:
            clazzName = obj.clazzName()
        except:
            try:
                obj.behavior
                try:
                    clazz = obj.clazz
                    clazzName = '<invalid class name>' #% PRIxPTR(clazz)
                except:
                    clazzName = '<invalid class>' #% PRIxPTR(self.small_header['behavior'])
            except:
                clazzName = '<invalid behavior>' #% PRIxPTR(self.small_header['behavior'])

        if clazzName.endswith(' class'):
            return "%s ( %s )" % ( PRIxPTR(obj) , clazzName[:-6] )
        elif clazzName == 'Metaclass':
            return "%s ( %s class )" % ( PRIxPTR(obj) , obj.slotAt(6).slotAt(6).chars())
        elif clazzName == 'Symbol':
            return "%s ( #%s )" % ( PRIxPTR(obj) , obj.chars())

        detail = None
        if clazzName == 'String':
            detail = obj.chars()
            if len(detail) > 10:
                detail = '"' + detail[:8] + '...'
            else:
                detail = '"' + detail + '"'
        elif clazzName == 'CompiledMethod' or clazzName == 'CallbackMethod':
            mclazz = getattr(obj, 'class')
            mclazz = mclazz.slotAt(6).chars() if mclazz.size() > 6 else mclazz.slotAt(6).slotAt(6).chars() + ' class'
            selector = obj.selector.chars()
            nA = obj.format.bits(CompiledMethodFlags.ArgCount)
            nT = obj.format.bits(CompiledMethodFlags.TempCount)
            codeAddr = int(obj.nativeCode.machineCode)
            codeSize = obj.nativeCode.machineCode.size()
            detail = "%s >> #%s nA %d nT %d code %s size %d" % ( mclazz , selector, nA, nT, PRIxPTR(codeAddr), codeSize)
        elif obj.isArrayed():
            if obj.isBytes():
                details = str(obj.size()) + ' bytes'
            else:
                details = str(obj.size()) + ' slots'

        if detail == None:
            return "%s ( a %s )" % ( PRIxPTR(obj) , clazzName )
        else:
            return "%s ( a %s, %s )" % ( PRIxPTR(obj) , clazzName, detail )

def _ObjectChildren(obj):
    """
    GDB will call this method on a pretty-printer to compute the children of
    the pretty-printer’s value.

    https://sourceware.org/gdb/onlinedocs/gdb/Pretty-Printing-API.html#Pretty-Printing-API
    """
    header = [  ('small_header' , obj.small_header ), ('behavior', obj.behavior._oop) ]
    if obj.isBytes():
        def mk_byte(index):
            return str(index) , gdb.Value(obj.byteAt(index)).cast(Types.char)
        return chain(header, map(lambda i: mk_byte(i), range(1, obj.size() + 1)))
    else:
        prefix = '' if obj.isArrayed() else 'slot'
        names = obj.slotNames()
        def mk_slot(index):
            if index < len(names) and names[index] != None:
                name = names[index]
            else:
                name = '%s%d' % (prefix, index + 1)
            return (name, obj.slotAt(index + 1)._oop)
        return chain(header, map(lambda i : mk_slot(i), range(0, obj.size())))

SmallInteger.to_string = _ObjectPrintString
SmallInteger.__str__ = _ObjectPrintString
SmallInteger.__repr__ = _ObjectPrintString
Object.to_string = _ObjectPrintString
Object.__str__ = _ObjectPrintString
Object.__repr__ = _ObjectPrintString
Object.children = _ObjectChildren

class oop(object):
    """
    A pretty printer for OOP, i.e., for object reference
    """
    def __init__(self, val):
        if isinstance(val, gdb.Value):
            # Not used yet, but will once we resurrect C++ magic
            #
            # if (val.type.code != gdb.TYPE_CODE_PTR) and val.type.name.startswith('BAST::OOP'):
            #    val = val['ptr']
            self._oop = val
        else:
            self._oop = gdb.Value(int(val)).cast(gdb.lookup_type('HeapObject').pointer())
        assert not self._oop.is_optimized_out

    def __str__(self):
        return self.to_string()

    def __int__(self):
        return int(self._oop)

    def to_string(self):
        adr = int(self._oop)
        if adr == 0:
            return "NULL"
        elif (adr & 1) == 1:
            ival = adr >> 1
            return (FMTxPTR + " ( SmallInteger: %d " + FMTxPTR + ")") % (self._oop, ival, ival)
        else:
            return obj(self._oop).to_string()

    def value(self):
        """
        Return gdb.Value representing self.
        """
        return self._oop

    @property
    def contents_visualizer(self):
        return obj


class CxxPrettyPrinter(PrettyPrinter):
    """
    This is specialized pretty printer for printing C++ class
    types.

    TBW.
    """

    class CxxSubPrinter(SubPrettyPrinter):
        def __init__(self, name, regexp, printer):
            super().__init__(name)
            self.regexp = regexp
            self.regexp_c = re.compile(regexp)
            self.printer = printer

        def matches(self, val_type):
            """
            Return True, if this subprinter can print `val`, False otherwise
            """
            if val_type.code == gdb.TYPE_CODE_PTR:
                val_type = val_type.target()
            try:
                if val_type.name != None and self.regexp_c.search(val_type.name):
                    return True
            except:
                pass
            return False

        def __call__(self, val):
            """
            Lookup the pretty-printer for the provided value.
            """
            if self.matches(val.type):
                return printer(val)
            else:
                return None

    def add_printer(self, name, regexp, printer):
        """Add a printer to the list.

        Add printer to the list.

        Arguments:
            name:    name of this pretty printer (for enable/disable)
            regexp:  the regular expression, as a string.
            printer: a callable that given a value returns an object to
                     pretty-print it.

        Returns:
            Nothing.
        """
        if self.subprinters == None:
            self.subprinters = []
        for subprinter in self.subprinters:
            if subprinter.regexp == regexp:
                subprinter.printer = printer
                return
        self.subprinters.append( CxxPrettyPrinter.CxxSubPrinter(name, regexp, printer) );

    def lookup(self, t):
        def basetypes(t):
            if t.code != gdb.TYPE_CODE_STRUCT:
                return None
            for f in t.fields():
                if f.is_base_class:
                    return f.type
            return None

        if self.subprinters == None:
            return None , None
        if t.code == gdb.TYPE_CODE_PTR:
            t = t.target()
        while t != None:
            for subprinter in self.subprinters:
                if subprinter.enabled and subprinter.matches(t):
                    return subprinter.printer , subprinter.regexp
            t = basetypes(t)
        return None, None

    def __call__(self, val):
        printer, ignored = self.lookup(val.dynamic_type)
        if printer != None:
            return printer(val)
        return None



def _build_pretty_printer():
    pp = CxxPrettyPrinter("Bee-DMR")
    pp.add_printer("HeapObject::SmallHeader", '^HeapObject::SmallHeader', None)
    pp.add_printer("HeapObject::LargeHeader", '^HeapObject::LargeHeader', None)
    pp.add_printer("HeapObject", "^HeapObject", oop)
    pp.add_printer("Object", "^Object", oop)
    return pp

register_pretty_printer(gdb, _build_pretty_printer(), replace = True)
