# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

import gdb

import powerlang.printing
import powerlang.symbols
import powerlang.cli

# Import following this namespace for convenience
# (when one uses Python interactively)
from powerlang.objectmemory import obj
from powerlang.cli import do, lm

# Intercept Launcher::launch() method and register
# a kernel segment
class __LaunchBreakpoint(gdb.Breakpoint):
    def stop(self):
        kernel = powerlang.objectmemory.ImageSegment('kernel')
        powerlang.objectmemory.segments.clear()
        powerlang.objectmemory.segments.append(kernel)
        return False # continue
__LaunchBreakpoint('Launcher::launch(ImageSegment*, int, char const**)', internal=True)
