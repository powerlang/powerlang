import sys
import re
import time
import threading
import argparse
from itertools import chain, islice

import gdb.printing
from gdb.unwinder import Unwinder
from gdb.FrameDecorator import FrameDecorator, SymValueWrapper
from pyparsing import *

# Define some type and constants from debug info. Hopefully in a future,
# this debug info would be somehow generated from Smalltalk code...
class Types:
    char = gdb.lookup_type('char')
    void = gdb.lookup_type('void')
    uintptr_t = gdb.lookup_type('uintptr_t')

    obj = gdb.lookup_type('S9::VMObject')
    oop = obj.pointer()
    small_header_t = gdb.lookup_type('pst::small_header_t')
    large_header_t = gdb.lookup_type('pst::large_header_t')

assert Types.uintptr_t.sizeof == 8

class ObjectFlags:
    IsBytes      = 1
    IsArrayed    = 2
    IsNamed      = 4
    IsRemembered = 8
    IsWeak       = 0x10
    HasBeenSeen  = 0x20
    IsSecondGen  = 0x40
    IsSmall      = 0x80


#
# Pretty printers
#
FMTxPTR = "0x%016x"
def PRIxPTR(value):
    return FMTxPTR % int(value)


class oop(object):
    """
    A pretty printer for OOP, i.e., for object reference
    """
    def __init__(self, val):
        if isinstance(val, gdb.Value):
            if (val.type.code != gdb.TYPE_CODE_PTR) and val.type.name.startswith('S9::OOP'):
                val = val['ptr']
            self._oop = val
        else:
            self._oop = gdb.Value(int(val)).cast(Types.oop)
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

def obj(oopish):
    return VMObject.create(oopish)

class VMSmallInteger(object):
    def __init__(self, val):
        assert val.type == Types.oop
        assert (int(val) & 1) == 1
        self._oop = val

    def __str__(self):
        return self.to_string()

    def __int__(self):
        return int(self._oop) >> 1

    def to_string(self):
        return (FMTxPTR + " ( SmallInteger: %d " + FMTxPTR + ")") % (self._oop, int(self), int(self))

    def isNil(self):
        return False

class VMObject(object):
    @staticmethod
    def create(oopish):
        obj_val = oopish
        if not isinstance(obj_val, gdb.Value):
            obj_val = oop(oopish).value()
        elif (obj_val.type.code != gdb.TYPE_CODE_PTR) and obj_val.type.name.startswith('S9::OOP'):
            obj_val = obj_val['ptr']
        if (int(obj_val) & 1) == 1:
            return VMSmallInteger(obj_val)
        return VMObject(obj_val)

    def __init__(self, val):
        # assert val.type == Types.oop
        self._oop = val
        self._small_header = None
        self._large_header = None

    def __int__(self):
        return int(self._oop)

    @property
    def small_header(self):
        """
        Return this object's small (base) header as an instance
        of `gdb.Value` of type `small_header_t`
        """
        if self._small_header == None:
            self._small_header = (self._oop.cast(Types.char.pointer()) - Types.small_header_t.sizeof).cast(Types.small_header_t.pointer())
        return self._small_header

    @property
    def large_header(self):
        """
        Return this object's large (extended) header as an instance
        of `gdb.Value` of type `large_header_t`. If object has no
        extended header, return None
        """
        if self.isSmall():
            return None
        else:
            if self._large_header == None:
                self._large_header = (self._oop.cast(Types.char.pointer()) - Types.small_header_t.sizeof - Types.large_header_t.sizeof).cast(Types.large_header_t.pointer())
        return self._large_header

    def flags(self):
        return self.small_header['flags']

    def isSmall(self):
        return (self.flags() & ObjectFlags.IsSmall) != 0

    def isBytes(self):
        return (self.flags() & ObjectFlags.IsBytes) != 0

    def isNamed(self):
        return (self.flags() & ObjectFlags.IsNamed) != 0

    def isZeroTerminated(self):
        """
        ProtoObject >> isZeroTerminated
        """
        return self.isArrayed()

    def isArrayed(self):
        return (self.flags() & ObjectFlags.IsArrayed) != 0

    def size(self):
        """
        Return size of an object excluding header(s) and excluding padding.

         * For byte objects, size is number of bytes.
         * For pointer objects, size is number od pointers.

        """
        if self.isSmall():
            return int(self.small_header['size'])
        else:
            return int(self.large_header['size'])

    @property
    def behavior(self):
        """
        Return this object's behavior as an (sub)instance
        of `_Object`.
        """
        if not hasattr(self, '_behavior'):
            self._behavior = self.__class__(self.small_header['behavior'].cast(Types.oop))
        return self._behavior

    @property
    def clazz(self):
        if not hasattr(self, '_clazz'):
            md  = self.behavior.value().cast(Types.oop.pointer()).dereference()
            clazz = VMObject.create((md + 2*Types.oop.sizeof).cast(Types.oop.pointer()).dereference())
            assert clazz.size() >= 6
            self._clazz = clazz
        return self._clazz

    def clazzName(self):
        if self.clazz.size() == 6:
            return "%s class" % self.clazz.slotAt(6).slotAt(6).chars()
        else:
            return self.clazz.slotAt(6).chars()

    def slotAt(self, index):
        """
        Return object given index as an instance of `VMObject`. Indexing
        starts at 1 as in Smalltalk.

        Assumes this is a pointer-indexed object.
        """
        assert not self.isBytes()
        assert index <= self.size()
        offset = (index - 1) * Types.oop.sizeof
        ptr = (self._oop.cast(Types.char.pointer()) + offset).cast(Types.oop.pointer())
        return self.__class__.create(ptr.dereference())

    def byteAt(self, index):
        """
        Return byte at given index. Indexing starts at 1 as in Smalltalk.

        Assumes this is a byte-indexed obhect.
        """
        assert self.isBytes()
        assert index <= self.size()
        offset = index - 1
        return int((self._oop + offset).cast(Types.char.pointer()).dereference())

    def chars(self):
        assert self.isBytes()
        char = self._oop.cast(Types.char.pointer())
        size = self.size()
        # if self._byteAt(size) == 0:
        #         size -= 1
        string = char.string('utf-8', 'replace', size)

        # Strip trailing null characters. Why they're there at all? Padding?
        while string[-1] == '\0':
            string = string[0:-1]
        return string

    def to_string(self):
        try:
            clazzName = self.clazzName()
        except:
            try:
                self.behavior
                try:
                    clazz = self.clazz
                    clazzName = '<invalid class name>' #% PRIxPTR(clazz)
                except:
                    clazzName = '<invalid class>' #% PRIxPTR(self.small_header['behavior'])
            except:
                clazzName = '<invalid behavior>' #% PRIxPTR(self.small_header['behavior'])

        if self.isArrayed():
            return "%s ( %s, size %d )" % ( PRIxPTR(self) , clazzName, self.size())
        else:
            return "%s ( %s )" % ( PRIxPTR(self) , clazzName )

    def children(self):
        """
        GDB will call this method on a pretty-printer to compute the children of
        the pretty-printer’s value.

        https://sourceware.org/gdb/onlinedocs/gdb/Pretty-Printing-API.html#Pretty-Printing-API
        """
        header = [  ('small_header' , self.small_header ),
                    ('behavior', self.behavior._oop) ]
        if self.isBytes():
            def mk_byte(index):
                return str(index) , gdb.Value(self.byteAt(index)).cast(Types.char)
            return chain(header, map(lambda i: mk_byte(i), range(1, self.size() + 1)))
        else:
            prefix = '' if self.isArrayed() else 'slot'
            def mk_slot(index):
                name = '%s%d' % (prefix, index + 1)
                return (name, self.slotAt(index + 1)._oop)
            return chain(header, map(lambda i : mk_slot(i), range(0, self.size())))

    def value(self):
        """
        Return gdb.Value representing self.
        """
        return self._oop


class CxxPrettyPrinter(gdb.printing.PrettyPrinter):
    """
    This is specialized pretty printer for printing C++ class
    types.

    TBW.
    """

    class CxxSubPrinter(gdb.printing.SubPrettyPrinter):
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
    pp = CxxPrettyPrinter("S9")
    pp.add_printer("OOP", "^S9::OOP", oop)
    pp.add_printer("VMObject", "^S9::VMObject", oop)
    return pp

gdb.printing.register_pretty_printer(gdb, _build_pretty_printer(), replace = True)



