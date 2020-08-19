/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef _OBJECT_H_
#define _OBJECT_H_

#include "Util.h"

struct HeapObject;
struct SmallInteger;

/**
 * Class `Object` represents an opaque object. It is meant to always
 * be used as a pointer, as it provides no direct access to its 
 * contents.
 * It could refer to an object heap or to an immediate object, and
 * must be cast to a particular type to use its actual value.
 */
struct Object
{

    /**
     * Return `true` if this object is a SmallInteger instance,
     * `false` otherwise.
     */
    bool isSmallInteger() { return (uintptr_t)this & 1 ? true : false; }

    /**
     * Cast into SmallInteger type
     */
    operator SmallInteger*()
    {
    	ASSERT(isSmallInteger());

    	return (SmallInteger*)(void*)this;
    }

    /**
     * Cast into SmallInteger type
     */
    SmallInteger* asSmallInteger() {return (SmallInteger*)this;}    

    /**
     * Cast into a HeapObject type
     */
    operator HeapObject*()
    {
    	ASSERT(!isSmallInteger());

    	return (HeapObject*)(void*)this;
    }

    /**
     * Cast into a HeapObject type
     */
    HeapObject* asHeapObject() {return (HeapObject*)this;}    


};

#endif /* _HEAPOBJECT_H_ */
