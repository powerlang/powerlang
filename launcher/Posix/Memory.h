/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef _MEMORY_H_
#define _MEMORY_H_

#include <unistd.h>
#include <cstdint>
#include "../Util.h"

uintptr_t AllocateMemory(uintptr_t base, uintptr_t size);

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

#endif // _MEMORY_H_

