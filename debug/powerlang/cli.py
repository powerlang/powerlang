# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contains GDB CLI commands and convenience variables/functions
"""

import gdb

from powerlang.printing import obj

def dump_object(expr):
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




class __DumpObjectCmd(gdb.Command):
	def invoke (self, args, from_tty):
		argv = gdb.string_to_argv(args)
		for arg in argv:
			dump_object(arg)

	def complete(self, text, word):
		return gdb.COMPLETE_EXPRESSION

__DumpObjectCmd('do', gdb.COMMAND_DATA)
