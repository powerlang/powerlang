/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef _HEAPOBJECT_H_
#define _HEAPOBJECT_H_

#include <string>

#include <Object.h>
#include <SmallInteger.h>
#include <Util.h>

typedef enum
{
    IsBytes      = 0x01,
    IsVariable   = 0x02,
    IsNamed      = 0x04,
    IsRemembered = 0x08,
    IsWeak       = 0x10,
    HasBeenSeen  = 0x20,
    IsSecondGen  = 0x40,
    IsSmall      = 0x80,
} HeapObjectFlags;

/**
 * Class `HeapObject` represents a Smalltalk object on an object heap
 * and provides very basic API to query object type and contents.
 */
struct HeapObject
{
#pragma pack (push,1)

    struct SmallHeader
    {
    	uint16_t hash;
    	uint8_t size;
    	uint8_t flags;
    	uint32_t behavior;

      /**
       * Casts buffer into a SmallHeader
       **/
      static SmallHeader* from(void* buffer) { return (SmallHeader*)buffer; }

      /**
       * Returns a reference to the HeapObject that corresponds to this header
       **/
      HeapObject* object() { return (HeapObject*)(((uintptr_t)this) + sizeof(SmallHeader)); }

    };

    struct LargeHeader
    {
    	uint32_t size;
    	uint32_t padding;
    	SmallHeader smallHeader;

      /**
       * Casts buffer into a LargeHeader
       **/
      static LargeHeader* from(void* buffer) { return (LargeHeader*)buffer; }

      /**
       * Returns a reference to the HeapObject that corresponds to this header
       **/
      HeapObject* object() { return smallHeader.object(); }
    };

    /**
     * struct `ObjectHeader` is an opaque handle to a header, in a similar
     * sense as Object: it represents the start of a header, and you have
     * to use its helpers to access the actual headers.
     **/
    struct ObjectHeader {

      /**
       * Casts buffer into an ObjectHeader
       **/
      static ObjectHeader* from(void* buffer) { return (ObjectHeader*)buffer; }

       /**
       * Determines whether this corresponds to a small or large header and returns the
       * SmallHeader part.
       **/
      SmallHeader* smallHeader() {
        auto small = (SmallHeader*)(void*)this;
        return (small->flags & IsSmall) ? small : &((LargeHeader*)(this))->smallHeader;
      }

      /**
       * Returns a reference to the HeapObject that corresponds to this header.
       * I check whether the header is large or small to add the corresponding
       * offset.
       **/
      HeapObject* object() { return this->smallHeader()->object(); }

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

    HeapObjectFlags flags()
    {
        return (HeapObjectFlags)(this->smallHeader()->flags);
    }

    /**
     * Return `true` if this object is byte-indexed, `false`
     * otherwise.
     */
    bool isBytes() { return flags() & IsBytes; }

    /**
     * Return `true` if this object is pointer-indexed, `false`
     * otherwise.
     */
    bool isPointers() { return !isBytes(); }

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
     * Returns the size of an object in bytes, including any padding needed and
     * *excluding* header.
     */
    size_t alignedSizeInBytes()
    {
    	return align(this->sizeInBytes(), sizeof(void*));
    }

    /**
     * Returns a reference to the header of the object immediately after the
     * receiver.
     * It is of an abstract type, as we don't know beforehand if it is small
     * or large.
     **/
    ObjectHeader* nextHeader()
    {
      uintptr_t nextHeader = (uintptr_t)this + this->alignedSizeInBytes();

      return (ObjectHeader*)nextHeader;
    }

    /**
     * Returns a reference to the object immediately after the receiver in the
     * heap.
     **/
    HeapObject* nextObject()
    {
      return this->nextHeader()->object();
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
static_assert(sizeof(HeapObject) == 1);

#endif /* _HEAPOBJECT_H_ */
