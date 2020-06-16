/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef UTIL_H_
#define UTIL_H_

#include <unistd.h>

#include <cstdint>
#include <cassert>

#ifndef ASSERT
#define ASSERT assert
#endif

static inline uintptr_t
align(uintptr_t value, int alignment)
{
    return ((value + (alignment - 1)) & ~(alignment - 1));
}

static inline uintptr_t
pagealign(uintptr_t addr)
{
    static int pagesize = -1;
    if (pagesize == -1) {
        pagesize = (int)sysconf(_SC_PAGESIZE);
        ASSERT(pagesize != -1);
    }
    return align(addr, pagesize);
}

#endif // UTIL_H_
