
#include <sys/mman.h>
#include <unistd.h>

#include "Memory.h"

uintptr_t AllocateMemory(uintptr_t base, uintptr_t size)
{
    return reinterpret_cast<uintptr_t>(mmap(reinterpret_cast<void*>(base),
                    pagealign(size),
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS,
                    0,
                    0));
}