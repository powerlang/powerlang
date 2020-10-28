# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

def bit(num):
    return num

def bits(lo, hi):
    return range(lo, hi)

class CompiledMethodFlags:
    """
    Encoding of CompiledMethod.format value. 

    Must be kept in sync with both SCompiledMethodFlags
    and CompiledMethod class >> initializeFormatFlags 

    In future, we may want to auto-generate these constants...
    """
    ArgCount        = bits(1,  6)
    BlockCount      = bits(7,  13)
    TempCount       = bits(14 ,21)
    CapturesSelf    = bit (22)
    HasEnvironment  = bit (23)
    HasFrame        = bit (24)
    Debuggable      = bit (25)
    EnvCount        = bits(26, 31)