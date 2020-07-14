/*
 * Copyright (c) 2020 Javier Pimas
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef _MEMORY_H_
#define _MEMORY_H_

#include <windows.h>
#include <cstdint>

#include "../Util.h"

uintptr_t AllocateMemory(uintptr_t base, uintptr_t size);

static inline uintptr_t
pagealign(uintptr_t addr)
{
    static int pagesize = -1;

    if (pagesize == -1)
    {
        SYSTEM_INFO si;
	    GetSystemInfo(&si);
        pagesize = si.dwPageSize;
    }
    return align(addr, pagesize);
}

#endif // _MEMORY_H_

