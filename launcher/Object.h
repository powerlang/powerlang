/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef OBJECT_H_
#define OBJECT_H_

#include <string>

#include "Util.h"

typedef enum
{
    IsBytes	     = 0x01,
    IsVariable   = 0x02,
    IsNamed      = 0x04,
    IsRemembered = 0x08,
    IsWeak       = 0x10,
    HasBeenSeen  = 0x20,
    IsSecondGen  = 0x40,
    IsSmall      = 0x80,

} ObjectFlags;

/**
 * Class `Object` represent a smalltalk object on an object heap
 * and provides very basic API to query object type and contents.
 */
struct Object
{
#pragma pack (push,1)
    struct SmallHeader
	{
    	uint16_t hash;
    	uint8_t size;
    	uint8_t flags;
    	uint32_t behavior;
	};

    struct LargeHeader
    {
    	uint32_t size;
    	uint32_t padding;
    	SmallHeader smallHeader;
    };
#pragma pack (pop)
  protected:

    SmallHeader* smallHeader()
    {
    	return (SmallHeader*)((uintptr_t)this - sizeof(SmallHeader));
    }

    LargeHeader* largeHeader()
    {
    	return (LargeHeader*)((uintptr_t)this - sizeof(LargeHeader));
    }


  public:
    static const intptr_t SMALLINT_MIN = INTPTR_MIN >> 1;
    static const intptr_t SMALLINT_MAX = INTPTR_MAX >> 1;

    ObjectFlags flags()
    {
        return (ObjectFlags)(this->smallHeader()->flags);
    }

    /**
     * Return `true` if this object is a SmallInteger instance,
     * `false` otherwise.
     */
    bool isSmallInt() { return (uintptr_t)this & 1 ? true : false; }

    /**
     * Return `true` if this object is byte-indexed, `false`
     * otherwise.
     */
    bool isBytes() { return !isSmallInt() && (flags() & IsBytes); }

    /**
     * Return `true` if this object is pointer-indexed, `false`
     * otherwise.
     */
    bool isPointers() { return !isSmallInt() && !isBytes(); }

    /**
     * Return a slot (pointer) of this object at given
     * index. Index starts at 0. This CAN be used to access
     * both named and indexed slots. This MUST be used only
     * with pointer-indexed objects.
     */
    Object* slot(uint32_t index);

    /**
     * Return a byte of this object at given index. Index
     * starts at 0. This MUST be used only with byte-indexed
     * objects.
     */
    uint8_t byte(uint32_t index);

    /**
     * Return bytes as std::string. This MUST be used only
     * with byte-indexed objects.
     */
    std::string stringVal();

    /**
     * Return size of an object. This is a number of slots
     * (pointers) for pointer-indexed objects or number of
     * bytes without padding for byte-indexed objects.
     */
    size_t size()
    {
    	if (flags() & IsSmall) {
    		return (size_t)smallHeader()->size;
    	} else {
    		return (size_t)largeHeader()->size;
    	}
    }

    /**
     * Return size of an object in bytes, *excluding* header
     * and excluding eventual alignment (for byte objects)
     */
    size_t sizeInBytes()
    {
    	if (isBytes()) {
    		return size();
    	} else {
    		return size() * sizeof(void*);
    	}
    }

    /**
     * Return aligned size of an object in bytes, *excluding* header.
     *
     */
    size_t sizeInBytesAligned()
    {
    	return align(this->sizeInBytes(), sizeof(void*));
    }


    /**
     * Assuming `this` represents a SmallInteger, return its
     * (signed) integer value
     */
    intptr_t smallIntVal()
    {
        ASSERT(isSmallInt());

        return (intptr_t)this >> 1;
    }

    /**
     * Assuming `this` represents a "small pointer"
     * return the value as pointer
     */
    template <typename T = void*>
    T smallPtrVal()
    {
        ASSERT(isSmallInt());

        return (T)((intptr_t)this & (intptr_t)~1);
    }

    /**
     * Return reference to SmallInteger object with
     * given `intVal`
     */
    static Object* smallIntObj(intptr_t intVal)
    {
    	ASSERT(SMALLINT_MIN <= intVal && intVal <= SMALLINT_MAX);

    	return (Object*)(((uintptr_t)intVal << 1) | 1);
    }

    /**
     * Return a reference SmallInteger object holding
     * a given `ptrVal` pointer boxed as "small pointer"
     */
    static Object* smallPtrObj(void* ptrVal)
    {
    	ASSERT(!((uintptr_t)ptrVal & 1));

    	return (Object*)((uintptr_t)ptrVal | 1);
    }

    class InvalidAccess
    {
      protected:
        std::string msg;

      public:
        InvalidAccess(const char* msg)
          : msg(msg)
        {}

        InvalidAccess(std::string msg)
          : msg(msg)
        {}
    };

};

// Here we just need to make sure the struct Object is empty.
// However, in C++, size of an empty struct / class is 1 byte,
// hence the `... == 1`
static_assert(sizeof(Object) == 1);


#endif /* OBJECT_H_ */
