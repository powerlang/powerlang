/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#include "Util.h"
#include "ImageSegment.h"
#include "Memory.h"



ImageSegment*
ImageSegment::alloc(uintptr_t base, size_t size)
{
    /*
     * TODO: In long run we should either use OMR port library or
     * take hmm.h / hmm.c from Smalltalk/X jv-branch runtime.
     */

    ASSERT(base == pagealign(base));
    auto ptr = AllocateMemory(base, size);
    ASSERT(base == ptr);
    return reinterpret_cast<ImageSegment*>(ptr);
}

ImageSegment*
ImageSegment::load(std::istream* data)
{
    ImageSegmentHeader header;

    data->read(reinterpret_cast<char*>(&header), sizeof(header));

    ImageSegment* segment = ImageSegment::alloc(header.baseAddress, header.reservedSize);

    data->seekg(0, data->beg);
    data->read(reinterpret_cast<char*>(segment), header.size);
    return segment;
}

