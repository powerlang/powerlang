# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

class MethodSymbol(object):
	def __init__(self, method, symtab):
		self.method = method

	@property
	def address(self):
		return int(self.method.nativeCode.machineCode)

	@property
	def size(self):
		return self.method.nativeCode.machineCode.size()

	@property
	def name(self):
		clazz = getattr(self.method, 'class')
		clazzName = clazz.slotAt(6).chars() if clazz.size() > 6 else clazz.slotAt(6).slotAt(6).chars()

		selector = self.method.selector.chars()
		return '%s >> #%s' % ( clazzName , selector)

	def __str__(self):
		return self.name

	def __int__(self):
		return self.address

	def __repr__(self):
		return "<MethodSymbol: 0x%016x, %4d, %s>" % ( self.address, self.size, self.name )

class SymbolTable(object):
	def __init__(self, segment):
		self._segment = segment
		
	def __iter__(self):
		return (MethodSymbol(mthd, self) for mthd in self._segment.find_instances_of('CompiledMethod') )

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