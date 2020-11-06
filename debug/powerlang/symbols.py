# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

from powerlang.utils import cached_generator, cache
from powerlang.constants import CompiledMethodFlags

class MethodSymbol(object):
    def __init__(self, method, symtab):
        self.method = method

    @property
    @cache
    def address(self):
        return int(self.method.nativeCode.machineCode)

    @property
    @cache
    def size(self):
        return self.method.nativeCode.machineCode.size()

    @property
    @cache
    def name(self):
        clazz = getattr(self.method, 'class')
        clazzName = clazz.slotAt(6).chars() if clazz.size() > 6 else clazz.slotAt(6).slotAt(6).chars() + ' class'

        selector = self.method.selector.chars()
        return '%s >> #%s' % ( clazzName , selector)

    def numArgs(self):
        return self.method.format.bits(CompiledMethodFlags.ArgCount)

    def numTmps(self):
        return self.method.format.bits(CompiledMethodFlags.TempCount)

    def isFrameLess(self):
        return self.method.format.bits(CompiledMethodFlags.HasFrame) == 0

    def isCallback(self):
        return self.method.clazzName() == 'CallbackMethod'

    def __str__(self):
        return ("M-sym: nA: %-2d nT: %-2d code: 0x%016x size: %-4d method: 0x%016x %s" % ( self.numArgs(), self.numTmps(), self.address, self.size, int(self.method), self.name ) )

    def __int__(self):
        return self.address

    def __repr__(self):
        return str(self)

class SymbolTable(object):
    def __init__(self, segment):
        self._segment = segment

    @property
    @cache
    def symbols(self):
        return cached_generator( (MethodSymbol(mthd, self) for mthd in self._segment.find_instances_of('CompiledMethod', 'CallbackMethod')) )

    def __iter__(self):
        return iter(self.symbols)

    def lookup_symbol_by_name(self, name):
        for sym in iter(self):
            if sym.name == name:
                return sym
        return None

    def lookup_symbol_by_addr(self, addr):
        for sym in iter(self):
            if sym.address <= int(addr) and int(addr) <= (sym.address + sym.size):
                return sym;
        return None




