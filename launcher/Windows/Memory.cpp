#include "Memory.h"

uintptr_t AllocateMemory(uintptr_t base, uintptr_t size)
{
    return reinterpret_cast<uintptr_t>(VirtualAlloc((void*)base,
                     pagealign(size), 
                     MEM_COMMIT,
                     PAGE_READWRITE));
}
