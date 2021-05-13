# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contains a stack unwinder for Powerlang/Bee

References:

 [1]: https://sourceware.org/gdb/current/onlinedocs/gdb/Unwinding-Frames-in-Python.html#Unwinding-Frames-in-Python
 [2]: https://github.com/tromey/spidermonkey-unwinder
 [3]: http://icedtea.classpath.org/people/adinn/unwinder/file/f50e52519fb9
#

"""

import gdb
import gdb.unwinder

from functools import lru_cache as cache

from powerlang.objectmemory import segments

def _lookup_symbol_by_addr(addr):
    for segment in segments:
        sym = segment.symtab.lookup_symbol_by_addr(int(addr))
        if sym != None:
            return sym
    return None

class MethodLinkage(object):
    PC_reg = 'rip'
    SP_reg = 'rsp'
    FP_reg = 'rbp'

    # Receiver / Return register (has to be set before calling a method)
    # Return value is passed in this register.
    # Volatile (caller-saved)
    R_reg  = 'rax'

    # Self register. You can trust self is always there. Before
    # a method leaves, it can restore the previous one from the
    # previous frame (after restoring the callers frame, caller's
    # self is in [rbp-8])
    # Preserved (callee-saved)
    S_reg  = 'rsi'

    # Environment register. It points to the last block context
    # pushed into the stack.
    # Preserved (callee-saved)
    E_reg  = 'rdi'

    # Argument register. In lookup the send site is passed through T
    # Volatile (caller-saved)
    A_reg  = 'rdx'

    # Temporal register. On super sends the CompiledMethod is
    # passed through it.
    # Volatile (caller-saved)
    T_reg  = 'rcx'

    # Volatile (scratch) register.
    # Volatile (caller-saved)
    V_reg  = 'r11'

    # Method register. While method is execution, M-register
    # points to currently executing method (in fact, to its NativeCode
    # object)
    # Preserved (callee-saved)
    M_reg  = 'rbx'


_char = gdb.lookup_type('char')


# And now the unwinder code comes, it consist of a couple of classes
# but the fundamental thing we need to know is the the stack layout and
# how the frame is built.
#
# For a reference, here's  annotated example of a method (thanks @pocho!)
#
# vdb > ds
# M-sym: nA: 2  nT: 0  code: 0x00000000202e6ea8 size: 35   method: 0x0000000020070b50 Kernel >> #entry:argv:
#   0x00000000202e6ea8: push   %rbp
#   0x00000000202e6ea9: mov    %rsp -> %rbp       ; new frame
#   0x00000000202e6eac: push   %rax               ; set frame's receiver slot
#   0x00000000202e6ead: mov    %rax -> %rsi       ; set receiver register
#   0x00000000202e6eb0: push   %rbx               ; set frame's native code slot
#   0x00000000202e6eb1: mov    $0xb -> %rax       ; load 5 into receiver
#   0x00000000202e6eb8: mov    0x10(%rbx) -> %rdx ; load sendsite factorial from native code
#   0x00000000202e6ebc: call   *(%rdx)
#   0x00000000202e6ebe: mov    %rbp -> %rsp       ; pop frame
#   0x00000000202e6ec1: pop    %rbp
#   0x00000000202e6ec2: mov    -0x8(%rbp) -> %rsi ; restore previous receiver
#   0x00000000202e6ec6: mov    -0x10(%rbp) -> %rbx; restore previous native code
#   0x00000000202e6eca: ret
# vdb >

class UnwindInfo(object):
    """
    This is a simple mock of GDB's UnwindInfo class that
    can be used to test Unwinder interactively. Just pass
    gdb.Frame as a pending_frame to unwinder.
    """

    def __init__(self, id):
        self.id = id
        self.regs = {}

    def add_saved_register(self, reg, value):
        self.regs[reg] = value

    def __str__(self):
        return "<unwind info: sp 0x%016x pc 0x%016x>" % ( int(self.id.sp), int(self.id.pc) )

class FrameInfo(object):
    def __init__(self, sp, fp, pc, symbol):
        self.sp = sp.cast(_char.pointer().pointer())
        self.fp = fp.cast(_char.pointer().pointer())
        self.pc = pc
        self.symbol = symbol
        self.linkage = MethodLinkage()

    def read_receiver(self):
        assert not self.symbol.isFrameLess()
        return self.fp[-1]

    def read_native_code(self):
        assert not self.symbol.isFrameLess()
        return self.fp[-2]

    def caller(self, pending_frame):
        """
        Return a caller frame info or so-called "sentinel frame", if
        the caller is not Powerlang / Bee frame (for example, C / C++ code)
        """
        if self.symbol == None:
            return self
        elif self.symbol.isFrameLess():
            raise Exception("FIXME!")
        else:
            # Determine CALLER sp and pc:
            sp = self.fp + 2
            pc = self.fp[1].cast(self.pc.type)
            symbol = _lookup_symbol_by_addr(pc)
            # Now we know the caller is JIT code so we have
            # to determine CALLERs fp
            #
            # Again, we have to be carefull as we may may have
            # be in the middle of prologue and so CALLER FP reg may
            # have not been saved in THIS frame!
            #
            # Here we assume the prologue has always the same form:
            #
            # 0x'202e6ea8 + 00: push   %rbp
            # 0x'202e6ea9 + 01: mov    %rsp -> %rbp       ; new frame
            # 0x'202e6eac + 04: push   %rax               ; set frame's receiver slot
            # 0x'202e6ead + 05: mov    %rax -> %rsi       ; set receiver register
            # 0x'202e6eb0 + 08: push   %rbx               ; set frame's native code slot
            #
            if self.pc < (self.symbol.address + 1):
                fp = pending_frame.read_register(self.linkage.FP_reg)
            else:
                fp = self.fp[0]
            return FrameInfo(sp, fp, pc, symbol)

    def create_unwind_info(self, pending_frame):
        id = FrameId(self.fp, self.pc)
        if hasattr(pending_frame, 'create_unwind_info'):
            ui = pending_frame.create_unwind_info(id)
        else:
            ui = UnwindInfo(id)

        # Now, for each (preserved) register overwritten
        # in THIS frame we have to `add_save_register()`
        # with CALLER's register value. See [1]:
        #
        #    Use `add_saved_register()` to specify caller registers
        #    that have been saved in this frame.
        #
        # [1]: https://sourceware.org/gdb/current/onlinedocs/gdb/Unwinding-Frames-in-Python.html#Unwinding-Frames-in-Python
        #
        caller = self.caller(pending_frame)

        ui.add_saved_register(caller.linkage.SP_reg, caller.sp)
        ui.add_saved_register(caller.linkage.FP_reg, caller.fp)
        ui.add_saved_register(caller.linkage.PC_reg, caller.pc)

        return ui

    def __repr__(self):
        if self.symbol == None:
            symname = '<foreign code>'
        else:
            symname = self.symbol.name
        return "<frame info: sp 0x%016x  fp 0x%016x  pc 0x%016x %s" % (int(self.sp), int(self.fp), int(self.pc), symname)

class FrameId(object):
    """
    A helper class used by GDB to identify a frame, see [1]

    [1]: https://sourceware.org/gdb/current/onlinedocs/gdb/Unwinding-Frames-in-Python.html#Unwinding-Frames-in-Python

    """
    def __init__(self, sp, pc):
        self.sp = sp
        self.pc = pc

class Unwinder(gdb.unwinder.Unwinder):
    def __init__(self):
        super().__init__('Powerlang-BeeDMR')

    def sniff(self, pending_frame):
        """
        Tries to 'sniff' on a pending_frame and if it looks like
        a JIT frame, return a FrameInfo. Otherwise, return None
        """

        # for now, only x86_64 is supported...
        assert pending_frame.architecture().name() == 'i386:x86-64'

        pc = pending_frame.read_register('rip')
        symbol = _lookup_symbol_by_addr(pc)
        if symbol == None:
            # We have not found any symbol for this PC, cannot unwind
            return None

        linkage = MethodLinkage() # TODO: really, we should ask symbol for its linkage!
        if symbol.isFrameLess():
            raise Exception("FIXME!");
        else:
            # Determine value FP. We cannot just read FP register
            # as we may be in the middle of prologue and therefore
            # FP register may still point to an old frame
            #
            # Assume the prologue is always in the same form:
            #
            # 0x'202e6ea8 + 00: push   %rbp
            # 0x'202e6ea9 + 01: mov    %rsp -> %rbp       ; new frame
            # 0x'202e6eac + 04: push   %rax               ; set frame's receiver slot
            # 0x'202e6ead + 05: mov    %rax -> %rsi       ; set receiver register
            # 0x'202e6eb0 + 08: push   %rbx               ; set frame's native code slot
            #
            sp = pending_frame.read_register(linkage.SP_reg)
            if pc < (symbol.address + 1):
                # caller's FP not yet saved nor FP register updated to this frame
                fp = sp - 8
            elif pc < (symbol.address + 4):
                # caller's FP saved but FP register not yet updated to this frame
                fp = sp
            else:
                # FP points to this frame
                fp = pending_frame.read_register(linkage.FP_reg)
            return FrameInfo(sp, fp, pc, symbol)

    def __call__(self, pending_frame):
        """
        The main unwinding method. It examines (sniffs at) a given frame and returns
        an object (an instance of gdb.UnwindInfo class) describing it. If
        an unwinder does not recognize a frame, it should return None.
        """
        fi = self.sniff(pending_frame)
        if fi == None:
            return None
        else:
            return fi.create_unwind_info(pending_frame)

# Finally, register the unwinder (globally):
gdb.unwinder.register_unwinder(None, Unwinder(), True)











