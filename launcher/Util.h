/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef _UTIL_H_
#define _UTIL_H_

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

#endif // _UTIL_H_

