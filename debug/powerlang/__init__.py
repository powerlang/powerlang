# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

import gdb

import powerlang.utils
import powerlang.objectmemory
import powerlang.printing
import powerlang.symbols
import powerlang.cli

# Import following this namespace for convenience
# (when one uses Python interactively)
import powerlang.objectmemory as om
from powerlang.objectmemory import obj
from powerlang.cli import do, ls, ds

# Intercept Launcher::launch() method and register
# a kernel segment
class __LaunchBreakpoint(gdb.Breakpoint):
    def stop(self):
        kernel = powerlang.objectmemory.ImageSegment('kernel')
        powerlang.objectmemory.segments.clear()
        powerlang.objectmemory.segments.append(kernel)
        print("Loading symbols from image segment, please wait...")
        kernel.symtab.load()
        print("...done!")
        return False # continue
__LaunchBreakpoint('Launcher::launch(ImageSegment*, int, char const**)', internal=True, temporary=True)


class __PythonReload(gdb.Command):
    """
    Reload Python code
    Usage: pr

    Reload Python code, making best-effort to update all
    code and cached objects to reflect new version. However,
    this is not perfect due to limitations of Python's
    importlib.reload().
    """
    def invoke (self, args, from_tty):
        self()

    def __call__(self):
        try:
            from importlib import reload
        except:
            from imp import reload

        powerlang.utils = reload(powerlang.utils)
        powerlang.objectmemory = reload(powerlang.objectmemory)
        powerlang.symbols = reload(powerlang.symbols)
        powerlang.printing = reload(powerlang.printing)
        powerlang.cli = reload(powerlang.cli)

pr = __PythonReload('pr', gdb.COMMAND_MAINTENANCE)
