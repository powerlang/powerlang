
#include <iostream>
#include <cstdio>
#include <climits>
#include <cstring>

#include "object_format.h"
#include "pst.h"

using namespace std; 
using namespace pst;

small_header_t* pst::small_header_cast(void* buffer)
{
	return (small_header_t*)buffer;
}

large_header_t* pst::large_header_cast(void* buffer)
{
	return (large_header_t*)buffer;
}

oop_t * pst::headerToObject(void * buffer)
{
	oop_t * object = ((oop_t *)buffer);
	return object->_isSmall() ? (oop_t *)((uintptr_t)buffer + 8) : (oop_t *)((uintptr_t)buffer + 16);
}


oop_t* pst::smiConst(uintptr_t number)
{
	return (oop_t*)((number << 1) | 1);
}

oop_t* pst::pointerConst(uintptr_t number)
{
	return (oop_t*)(number | 1);
}

oop_t* pst::asObject(void *smallPointer)
{
	return (oop_t*)asUObject(smallPointer);
}

uintptr_t pst::asUObject(void *smallPointer)
{
	return (uintptr_t)smallPointer & ~1;
}

// size calculation

uint8_t oop_t::_smallSize()
{
	return this->small_header()->size;
}

void oop_t::_smallSize(uint8_t size)
{
	this->small_header()->size = (char)size;
}


uint32_t oop_t::_largeSize()
{
	return this->large_header()->size;
}


void oop_t::_largeSize(uint32_t size)
{
	this->large_header()->size = size;
}

uint32_t oop_t::_size()
{
	uint32_t total;
	if (this->_isSmall())
		total = this->_smallSize();
	else
		total = this->_largeSize();

	return total;
}

uint32_t oop_t::_sizeInBytes()
{
	if (this->_isBytes())
	{
		return (this->_size() + WORD_SIZE - 1) & (-WORD_SIZE);

	} else
		return this->_size() * WORD_SIZE;
}



uint32_t oop_t::_headerSizeInBytes()
{
	if (this->_isSmall())
	{
		return 8;
	} 
	else
	{
		return 16;
	}
}

uint32_t pst::oop_t::_slotsSize()
{
	uint32_t size = this->_size();

	return this->_isBytes() ? ((size + WORD_SIZE - 1) >> WORD_SIZE_SHIFT) : size;
}


uint32_t oop_t::_pointersSize()
{
	if (this->_isBytes())
		return 0;
	else
		return this->_size();
}

uint32_t oop_t::_strongPointersSize()
{
	if (this->_isBytes() || this->_isWeak())
		return 0;
	else
		return this->_size();
}


// flags manipulation

bool oop_t::testFlags(unsigned char flag)
{
	return (this->small_header()->flags & (flag)) == flag;
}

void oop_t::setFlags(unsigned char flag)
{
	this->small_header()->flags |= flag;
}

void oop_t::unsetFlags(unsigned char flag)
{
	this->small_header()->flags &= (flag) ^ small_header_t::ObjectFlagMaxValue;
}

void oop_t::_beSmall()
{
	this->setFlags(small_header_t::Flag_isSmall);
}

void pst::oop_t::_beLarge()
{
	this->unsetFlags(small_header_t::Flag_isSmall);
}

bool oop_t::_isNamed()
{
	return this->testFlags(small_header_t::Flag_isWeak);
}

bool oop_t::_isWeak()
{
	return this->testFlags(small_header_t::Flag_isWeak);
}

void oop_t::_beStrong()
{
	this->unsetFlags(small_header_t::Flag_isWeak);
}

void oop_t::_beSecondGeneration()
{
	this->setFlags(small_header_t::Flag_isSecondGen);
}

bool oop_t::_isSecondGeneration()
{
	return this->testFlags(small_header_t::Flag_isSecondGen);
}

bool oop_t::_isBytes()
{
	return this->testFlags(small_header_t::Flag_isBytes);
}

bool oop_t::_isSmall()
{
	return this->testFlags(small_header_t::Flag_isSmall);
}


bool oop_t::_isRemembered()
{
	return this->testFlags(small_header_t::Flag_isRemembered);
}

void oop_t::_beNotRemembered()
{
	this->unsetFlags(small_header_t::Flag_isRemembered);
}

void oop_t::_beRemembered()
{
	this->setFlags(small_header_t::Flag_isRemembered);
}

void oop_t::_beSeen()
{
	this->setFlags(small_header_t::Flag_hasBeenSeen);
}

void oop_t::_beUnseen()
{
	this->unsetFlags(small_header_t::Flag_hasBeenSeen);
}


bool oop_t::_hasBeenSeen()
{
	return this->testFlags(small_header_t::Flag_hasBeenSeen);
}

oop_t * oop_t::nextObject()
{
	uint32_t completeSizeOfObject = this->_sizeInBytes();
	uintptr_t nextHeader = ((uintptr_t) this + completeSizeOfObject);
	return headerToObject((oop_t*) nextHeader);
}




void pst::_halt()
{
	perror("_halt encountered");
}


