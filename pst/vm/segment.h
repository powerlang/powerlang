/*
 * Copyright (c) 2019 Javier Pimas, Jan Vrany

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef _SEGMENT_H_
#define _SEGMENT_H_

#include <cstdint>
#include <iostream>
#include "pst.h"
#include "object_format.h"

namespace pst
{

typedef struct _segment_header
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
    uint64_t base_address;
    /**
     * Size of a segment including its header
     */
    uint64_t size;
    /**
     * A reference to an entry point method object.
     */
    oop_t *entry_point_method;
} segment_header;

static_assert(sizeof(segment_header) == 32/*bytes*/,
              "segment_header size not 32bytes");


class segment
{
public:
    segment_header header;

    /**
     * Allocate a new segment of given `size` at given `base` address.
     * Contents of the swgment is zeroed.
     */
    static segment *alloc(uintptr_t base, size_t size);

    /**
     * Load a segment from given stream and return it. The stream should
     * be positioned to the beggining of segment prior calling load()
     */
    static segment *load(std::istream *data);
};

} // namespace pst

#endif // _SEGMENT_H_