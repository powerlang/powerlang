# Copyright (c) 2020 Javier Pimas & LabWare
#
# This program and the accompanying materials are made available under
# the terms of the MIT license, see LICENSE file.
#
# SPDX-License-Identifier: MIT

"""
This module contains a set of utility methods and classes
for general use.
"""

from itertools import chain
from functools import lru_cache

def cache(user_function):
    """
    Simple lightweight unbounded function cache. Sometimes called “memoize”.
    """
    return lru_cache(maxsize=None, typed=False)(user_function)

class cached_generator(object):
    """
    A `cached_generator` is a wrapper around any generator
    (iterable) that caches generated values so next time the
    generator is iterated over, it does not need to compute
    values, the cached ones are returned.

    WARNING: Not thread-safe!
    """
    def __init__(self, generator):
        self._head = []
        self._tail = generator

    def __iter__(self):
        def cache(value):
            self._head.append(value)
            return value
        head_it = (self._head[idx] for idx in range(0, len(self._head)))
        tail_it = (cache(sym)     for sym in self._tail)
        return chain(head_it, tail_it)
