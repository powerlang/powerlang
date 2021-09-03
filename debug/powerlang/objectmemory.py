# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contains classes and functions to
model image objects (i.e., Smalltalk objects)
"""

import gdb

from itertools import chain

from powerlang.utils import cache
from powerlang.symbols import SymbolTable

flatten = chain.from_iterable

def align(value, alignment):
    return ((int(value) + (alignment - 1)) & ~(alignment - 1))

# Define some type and constants from debug info. Hopefully in a future,
# this debug info would be somehow generated from Smalltalk code...
class Types:
    char = gdb.lookup_type('char')
    void = gdb.lookup_type('void')
    uintptr_t = gdb.lookup_type('uintptr_t')

    obj = gdb.lookup_type('HeapObject')
    oop = obj.pointer()
    small_header_t = gdb.lookup_type('HeapObject::SmallHeader')
    large_header_t = gdb.lookup_type('HeapObject::LargeHeader')

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

class ObjectIndices:
    Behavior_class              = 1
    Behavior_methods            = 2
    Behavior_next               = 3

    Species_superclass          = 1
    Species_instanceBehavior    = 2
    Species_format              = 3
    Species_organization        = 4
    Species_instanceVariables   = 5

    Class_name                  = 6
    Class_subclasses            = 7
    Class_classVariables        = 8
    Class_sharedPools           = 9

    Metaclass_class             = 6

def _as_gdb_value(valueish, typ):
    if isinstance(valueish, gdb.Value):
        assert valueish.type.code == typ.code
        return valueish.cast(typ)
    elif isinstance(valueish, int):
        return gdb.Value(valueish).cast(typ)
    elif isinstance(valueish, str):
        val = gdb.parse_and_eval(valueish)
        if val.type.code == gdb.TYPE_CODE_INT and typ.code == gdb.TYPE_CODE_PTR:
            val = val.cast(typ)
        assert val.type.code == typ.code, "%s evaluated to a gdb.Value of a different type"
        return val
    else:
        raise ValueError("Invalid argument type (valueish")

def _as_oop_value(valueish):
    return _as_gdb_value(valueish, Types.oop)


class __ObjectABC(object):
    """
    Base abstract superclass for both a full object
    and (immediate) small integers.
    """

    def __init__(self, val):
        assert isinstance(val, gdb.Value)
        self._oop = val

    def __hash__(self):
        return hash(int(self._oop))

    def __eq__(self, other):
        return (
            self.__class__ == other.__class__
            and self._oop == other._oop
        )

class SmallInteger(__ObjectABC):
    def __init__(self, val):
        assert val.type == Types.oop
        assert (int(val) & 1) == 1
        super().__init__(val)

    def __int__(self):
        return int(self._oop) >> 1

    def isNil(self):
        return False

    def isSmallInteger(self):
        return True

    def bits(self, bits):
        if isinstance(bits, int):
            return 1 if (int(self) & (1 << bits-1)) > 0 else 0
        elif isinstance(bits, range):
            mask = (-1 << bits.stop) ^ (-1 << (bits.start - 1))
            shift = bits.start - 1
            return (int(self) & mask) >> shift
        else:
            raise ArgumentError("Invalid bits specifier - must be either int or range")

    def references(self, oopish):
        """
        Return True if self references given object,
        False otherwise
        """
        return False


class Object(__ObjectABC):
    def __init__(self, val):
        super().__init__(val)

    def isNil(self):
        try:
            if self.clazzName() == 'UndefinedObject':
                return True
        except:
            pass
        return False

    def isSmallInteger(self):
        return False

    def __int__(self):
        return int(self._oop)

    @property
    @cache
    def small_header(self):
        """
        Return this object's small (base) header as an instance
        of `gdb.Value` of type `small_header_t`
        """
        return (self._oop.cast(Types.char.pointer()) - Types.small_header_t.sizeof).cast(Types.small_header_t.pointer())

    @property
    @cache
    def large_header(self):
        """
        Return this object's large (extended) header as an instance
        of `gdb.Value` of type `large_header_t`. If object has no
        extended header, return None
        """
        if self.isSmall():
            return None
        else:
            return (self._oop.cast(Types.char.pointer()) - Types.large_header_t.sizeof).cast(Types.large_header_t.pointer())

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

    def sizeInBytes(self):
        """
        Return size of an object in bytes, *excluding* header
        and excluding eventual alignment (for byte objects)
        """
        if self.isBytes():
            return self.size()
        else:
            return self.size() * Types.oop.sizeof

    def sizeInBytesAligned(self):
        return align(self.sizeInBytes(), Types.oop.sizeof);

    @property
    @cache
    def behavior(self):
        """
        Return this object's behavior as an (sub)instance
        of `_Object`.
        """
        base = (int(self._oop) >> 32) << 32
        offset = self.small_header['behavior']
        return self.__class__((base+offset).cast(Types.oop))

    @property
    @cache
    def clazz(self):
        clazz = self.behavior.slotAt(ObjectIndices.Behavior_class)
        assert clazz.size() >= 6
        return clazz

    @cache
    def clazzName(self):
        if self.clazz.size() == 6:
            return "%s class" % self.clazz.slotAt(ObjectIndices.Metaclass_class).slotAt(ObjectIndices.Class_name).chars()
        else:
            return self.clazz.slotAt(ObjectIndices.Class_name).chars()

    @cache
    def slotNames(self):
        """
        Return a list of instance variable names fot this object
        (as python list of python strings)
        """
        def slotName(array, index):
            if index >= 1 and index <= array.size():
                name = array.slotAt(index)
                if name.isBytes():
                    return name.chars()
            return 'slot%d' % index

        slotNames = []

        current = self.clazz
        while current.size() >= 6:
            currentIvars = current.slotAt(ObjectIndices.Species_instanceVariables)
            slotNames = slotNames + [ slotName(currentIvars, i) for i in reversed(range(1, currentIvars.size()+1))]
            current = current.slotAt(ObjectIndices.Species_superclass)
        return list(reversed(slotNames))

    @cache
    def slotAt(self, index):
        """
        Return object given index as an instance of `Object`. Indexing
        starts at 1 as in Smalltalk.

        Assumes this is a pointer-indexed object.
        """
        assert not self.isBytes()
        assert index >= 1
        assert index <= self.size()
        offset = (index - 1) * Types.oop.sizeof
        ptr = (self._oop.cast(Types.char.pointer()) + offset).cast(Types.oop.pointer())
        return obj(ptr.dereference())

    def slots(self):
        """
        Return a list of slot values (references to other objects)
        """
        if self.isBytes():
            return []
        else:
            return [ self.slotAt(i) for i in range(1, self.size() + 1) ]

    def byteAt(self, index):
        """
        Return byte at given index. Indexing starts at 1 as in Smalltalk.

        Assumes this is a byte-indexed obhect.
        """
        assert self.isBytes()
        assert index >= 1
        assert index <= self.size()
        offset = index - 1
        return int((self._oop + offset).cast(Types.char.pointer()).dereference())

    def __getattr__(self, name):
        if name[0] == '_':
            return super().__getattr__(name)
        else:
            names = self.slotNames();
            if name in names:
                return self.slotAt(names.index(name) + 1)
            else:
                raise AttributeError("Instance of class %s has no slot named '%s'" % ( self.clazzName() , name ))

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

    def references(self, oopish):
        if not self.isBytes():
            refd_obj = obj(oopish)
            for slot_obj in self.slots():
                if slot_obj == refd_obj:
                    return True
        return False

    def value(self):
        """
        Return gdb.Value representing self.
        """
        return self._oop

def obj(oopish):
    """
    Convenience function to create a representation
    of an object for given oopish.
    """
    if isinstance(oopish, __ObjectABC):
        return oopish
    else:
        oop_val = _as_oop_value(oopish)
        if (int(oop_val) & 1) == 1:
            return SmallInteger(oop_val)
        else:
            return Object(oop_val)

class ObjectIterator(object):
    def __init__(self, lo, hi):
        self._curr = int(lo)
        self._stop = int(hi)

    def __iter__(self):
        return self

    def __next__(self):
        if self._curr < self._stop:
            p = self._curr
            o = obj(p);

            # Now, advance p to point to next object
            p += o.sizeInBytesAligned()
            hdr = gdb.Value(p).cast(Types.small_header_t.pointer())
            if int(hdr['behavior']) == 0:
                p += Types.large_header_t.sizeof
            else:
                p += Types.small_header_t.sizeof
            self._curr = p;
            return o
        else:
            raise StopIteration  # signals "the end"

class ImageSegment(object):
    """
    A represenation of an image segment as produced by
    bootstrapper.
    """

    def __init__(self, ptr):
        self._ptr = _as_gdb_value(ptr, gdb.lookup_type("ImageSegment").pointer())
        self._size = int(self._ptr['header']['size'])

    def __iter__(self):
        lo = int(self._ptr) + self._ptr['header'].type.sizeof + Types.small_header_t.sizeof
        hi = lo + self._ptr['header']['size'] - self._ptr['header'].type.sizeof
        return ObjectIterator(lo, hi)

    @property
    @cache
    def symtab(self):
        return SymbolTable(self)

    def find_instances_of(self, *oopishes_or_classnames):
        """
        Return an iterator over all instances of given class(es).
        """
        clazzes = []
        for oopish_or_classname in oopishes_or_classnames:
            if isinstance(oopish_or_classname, str):
                clazz = self.find_class(oopish_or_classname)
            else:
                clazz = obj(oopish_or_classname)
            if clazz != None:
                clazzes.append(clazz)

        return (obj for obj in iter(self) if obj.clazz in clazzes)

    def find_class(self, name):
        for o in iter(self):
            try:
                if o.clazzName() == (name + ' class'):
                    return o
            except:
                pass
        return None

    def find_object_at(self, addrish):
        """
        Return an object at given addish or None if no object
        contains that address
        """
        addr = int(addrish)
        for o in iter(self):
            lo = int(o)
            hi = lo + o.sizeInBytes()
            if lo <= addr and addr < hi:
                return o
        return None

    def find_references_to(self, oopish):
        """
        Return an iterator over all object referencing
        given oopish.
        """
        o = obj(oopish)
        return (r for r in iter(self) if r.references(o))

def find_object_at(addrish):
    """
    Return an object at given addish or None if no object
    contains that address
    """
    for segment in segments:
        o = segment.find_object_at(addrish)
        if o != None:
            return o
    return None

def find_references_to(oopish):
    """
    Return an iterator over all object referencing
    given oopish.
    """
    return flatten( segment.find_references_to(oopish) for segment in segments )




# A list of all known segments. The main module should intercept
# segment loading (especially loading kernel segment) and register
# it here.
# Here we use try: except NameError: idiom to support module reloading
try:
    segments
    # If we arrive here it means the code has been reloaded
    # in running GDB, so we re-instantiate segments to make sure
    # new code has been loaded and used.
    segments = [ImageSegment(segment._ptr) for segment in segments]
    for segment in segments:
        segment.symtab.load()
except NameError:
    segments = []



# Flush known segments when inferior exits:
def __on_exit(event):
    segments = []

gdb.events.exited.connect(__on_exit)
