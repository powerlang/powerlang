/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#include <sys/mman.h>
#include <unistd.h>

#include "Util.h"
#include "ImageSegment.h"


ImageSegment*
ImageSegment::alloc(uintptr_t base, size_t size)
{
    /*
     * TODO: Following implementation is rubbish, in long run we should either
     * use OMR port library or take hmm.h / hmm.c from Smalltalk/X jv-branch
     * runtime.
     * But it will do for now.
     */

    ASSERT(base == pagealign(base));
    auto ptr = mmap(reinterpret_cast<void*>(base),
                    pagealign(size),
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS,
                    0,
                    0);
    ASSERT(base == reinterpret_cast<uintptr_t>(ptr));
    return reinterpret_cast<ImageSegment*>(ptr);
}

ImageSegment*
ImageSegment::load(std::istream* data)
{
    ImageSegmentHeader header;

    data->read(reinterpret_cast<char*>(&header), sizeof(header));

    ImageSegment* segment = ImageSegment::alloc(header.baseAddress, header.size);

    data->seekg(0, data->beg);
    data->read(reinterpret_cast<char*>(segment), header.size);
    return segment;
}

