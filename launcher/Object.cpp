/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#include "Object.h"



Object*
Object::slot(uint32_t index)
{
    ASSERT(!this->isBytes());
    ASSERT(/*index >= 0 &&*/ index <= this->size());

    Object** slot = (Object**)this + index;
    return *slot;
}

uint8_t
Object::byte(uint32_t index)
{
    ASSERT(this->isBytes());
    ASSERT(index <= this->size());

    return *(((uint8_t*)this) + index);
}

std::string
Object::stringVal()
{
	ASSERT(this->isBytes());

    std::string str((const char*)this, this->size());
    return str;
}

