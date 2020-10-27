/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef IMAGESEGMENT_H_
#define IMAGESEGMENT_H_

#include <cstdint>
#include <iostream>
#include <iterator>

#include <HeapObject.h>

typedef struct _ImageSegmentHeader
{
    /**
     * Signature of a PST segment, must be following sequence:
     * { 'P' , '_', 'I', 'M' , '_', 'S', '\n', '\0' }
     */
    uint8_t signature[8];
    /**
     * Assumed base address at which segment is loaded, including
     * its segment header. Implementations are free to load segment at
     * any other address in which case object references (including the
     * `entry_point_method` reference!) must be relocated prior use.
     */
    uint64_t baseAddress;
    /**
     * Size of a segment including its header
     */
    uint64_t size;
    /**
     * A reference to Module instance describing this image segment
     */
    HeapObject* module;

} ImageSegmentHeader;

static_assert(sizeof(ImageSegmentHeader) == 32 /*bytes*/,
              "segment_header size not 32bytes");

class ImageSegment
{
  public:
    ImageSegmentHeader header;

    /**
     * Allocate a new segment of given `size` at given `base` address.
     * Contents of the segment is zeroed.
     */
    static ImageSegment* alloc(uintptr_t base, size_t size);

    /**
     * Load a segment from given stream and return it. The stream should
     * be positioned to the beginning of segment prior calling load()
     */
    static ImageSegment* load(std::istream* data);
};

#endif // IMAGESEGMENT_H_
