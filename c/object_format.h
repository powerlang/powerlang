
#ifndef _OBJECT_FORMAT_H_
#define _OBJECT_FORMAT_H_

#include <cassert>

#ifndef ASSERT
#define ASSERT assert
#endif

/* 
 *
 * Here we define the most basic thing to the VM: the object format.
 * This is an initial implementation, we expect to allow for different
 * formats in the future.
 *
 * This file defines first the object header types (small and large).
 * Finally, the oop_t is defined, which acts as a handle to objects,
 * that lets us access the header and the slots.
 *
 */

#include "pst.h"

#define SMI_CLEAR_FLAG -2

namespace pst
{

//#pragma pack (1)
#pragma pack (push,1)
typedef struct small_header_t
{
	uint16_t hash;
	uint8_t size;
	uint8_t flags;
	uint32_t behavior;

	void _hash (uint32_t hash)  { ASSERT(hash  <= 0xFFFF); this->hash  = (uint16_t)hash; }
	void _size (uint32_t size)  { ASSERT(size  <= 0xFF);   this->size  = (uint8_t)size; }
	void _flags(uint32_t flags) { ASSERT(flags <= 0xFF);   this->flags = (uint8_t)flags; }
	void _behavior(oop_t *behavior) { this->behavior = (uint32_t)(uintptr_t)behavior; }
	oop_t* _behavior() { return (oop_t*)(uintptr_t)this->behavior; }

	oop_t* slots() { return (oop_t*)((intptr_t)this + 8); }
	small_header_t* actual_small_header()
	{ 
		(this->flags & Flag_isSmall) ? this : (small_header_t*)((uintptr_t)this) + 8;
	}


	
	static const uint8_t Flag_isBytes      = 1;
	static const uint8_t Flag_isArrayed    = 2;
	static const uint8_t Flag_isNamed      = 4;
	static const uint8_t Flag_isRemembered = 8;
	static const uint8_t Flag_isWeak       = 0x10;
	static const uint8_t Flag_hasBeenSeen  = 0x20;
	static const uint8_t Flag_isSecondGen  = 0x40;
	static const uint8_t Flag_isSmall      = 0x80;

	static const uint8_t ObjectFlagMaxValue = 0xFF;

} small_header_t;

typedef struct large_header_t
{
	uint32_t size;				// 4
	uint32_t reserved;			// 4
	small_header_t small_header;

	void _size (uint32_t size)       { this->size  = size; }
	void _behavior(oop_t *behavior)  { this->small_header._behavior(behavior); }

	oop_t* slots() { return (oop_t*)((uintptr_t)this + 16); }
} large_header_t;

#pragma pack (pop)



oop_t* smiConst(uintptr_t number);
oop_t* pointerConst(uintptr_t number);
oop_t* asObject(void *smallPointer);

uintptr_t  asUObject(void *smallPointer);

struct oop_t
{
public:

	bool isSmallInteger() { return ((uintptr_t)this & 1) == 1; }
	bool isSmallInteger() volatile { return ((uintptr_t)this & 1) == 1; }

	// small integers
	oop_t* smiPlusNative(int b) { return (oop_t*)(((uintptr_t)this & SMI_CLEAR_FLAG) + (uintptr_t)smiConst(b)); }
	uintptr_t _asNative() { return (uintptr_t)this >> 1; }
	void*  _asObject()    { return (void*)((uintptr_t)this & ~1); }
	oop_t* _asPointer()   { return isSmallInteger() ? (oop_t*)_asNative() : pointerConst((uintptr_t)this); }

	// volatile versions for syncpoints
	oop_t* smiPlusNative(int b) volatile { return (oop_t*)(((uintptr_t)this & SMI_CLEAR_FLAG) + (uintptr_t)smiConst(b)); }
	uintptr_t _asNative() volatile { return (uintptr_t)this >> 1; }
	void*  _asObject()    volatile { return (void*)((uintptr_t)this & ~1); }
	oop_t* _asPointer()   volatile { return isSmallInteger() ? (oop_t*)_asNative() : pointerConst((uintptr_t)this); }


	small_header_t* small_header() { return (small_header_t*)((uintptr_t)this- 8); }
	large_header_t* large_header() { return (large_header_t*)((uintptr_t)this-16); }


	uint8_t  _smallSize();
	void     _smallSize(uint8_t size);
	uint32_t _largeSize();
	void     _largeSize(uint32_t size);

	uint32_t _size();
	uint32_t _sizeInBytes();
	uint32_t _headerSizeInBytes();

	uint32_t _slotsSize();
	uint32_t _pointersSize();
	uint32_t _strongPointersSize();


	// flags
	bool _isBytes();
	bool _isArrayed();
	bool _isNamed();
	bool _isRemembered();
	bool _isWeak();
	bool _hasBeenSeen();
	bool _isSecondGeneration();
	bool _isSmall();
	
	void _beRemembered();
	void _beNotRemembered();
	void _beSecondGeneration();
	void _beSmall();
	void _beLarge();

	void _beStrong();
	
	void _beSeen();
	void _beUnseen();

	bool testFlags    (unsigned char flag);
	void setFlags     (unsigned char flag);
	void unsetFlags   (unsigned char flag);


	// behavior and slots

	oop_t* behavior() {
		return this->small_header()->_behavior();
	}
	
	void behavior(oop_t *behavior) { 
		return this->small_header()->_behavior(behavior);
	}
	
	slot_t& slot(uint32_t index) { 
		uintptr_t *pos = (uintptr_t*)this + index;
		return *((slot_t*)pos);
	}
	
	uint8_t&  byte(long index) {
		uint8_t *pos = (uint8_t*)this + index;
		return *pos;
	}
	
	oop_t* nextObject();

};


small_header_t* small_header_cast(void* buffer);
large_header_t* large_header_cast(void* buffer);

oop_t* headerToObject(void* buffer);

// others

void   _free(uint32_t * limit, uint32_t * delta);
void _halt();
oop_t* _framePointer();


}

#endif // ~ _OBJECT_FORMAT_H_

