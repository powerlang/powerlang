/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef _SMALL_INTEGER_H_
#define _SMALL_INTEGER_H_

#include "Util.h"

struct Object;

/**
 * Class `SmallInteger` represents an immediate small integer, encoded
 * in a pointer. It is signed and tagged with 1 in its least significant
 * bit. It is always held as a pointer.
 */
struct SmallInteger
{
    static const intptr_t SMALLINT_MIN = INTPTR_MIN >> 1;
    static const intptr_t SMALLINT_MAX = INTPTR_MAX >> 1;

    /**
     * Cast back into an opaque Object type
     **/
    operator Object*() {return (Object*)(void*)this; }

    /**
     * Cast back into an opaque Object type
     **/
    Object* object() { return (Object*)this; }
 
    /**
     * Return reference to a SmallInteger object with
     * given `intVal`
     */
    static SmallInteger* from(intptr_t intVal)
    {
    	ASSERT(SMALLINT_MIN <= intVal && intVal <= SMALLINT_MAX);

    	return (SmallInteger*)(((uintptr_t)intVal << 1) | 1);
    }

    /**
     * Return a reference to SmallInteger object holding
     * a given `ptrVal` pointer encoded as "small pointer"
     */
    static SmallInteger* from(void* ptrVal)
    {
    	ASSERT(!((uintptr_t)ptrVal & 1));

    	return (SmallInteger*)((uintptr_t)ptrVal | 1);
    }

    /**
     * Assuming `this` encodes a SmallInteger, decode its
     * (signed) integer value
     */
   intptr_t asNative()
    {
        ASSERT(this->object()->isSmallInteger());

        return (intptr_t)this >> 1;
    }

    /**
     * Assuming `this` encodes a pointer stored as a SmallInteger,
     * return the value of the original pointer
     */
    template <typename T = void*>
    T asPointer()
    {
        ASSERT(this->object()->isSmallInteger());

        return (T)((intptr_t)this & (intptr_t)~1);
    }

};

#endif /* _SMALL_INTEGER_H_ */
