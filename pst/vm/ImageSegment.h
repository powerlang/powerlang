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
#include <iterator>

#include <Object.h>
#include <Classes.h>

namespace S9 {

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
     * A reference to an entry point method object.
     */
    OOP<VMObject> toc;

} ImageSegmentHeader;

static_assert(sizeof(ImageSegmentHeader) == 32 /*bytes*/,
              "segment_header size not 32bytes");

class ImageSegment
{
  private:
    class iterator;

  public:
    ImageSegmentHeader header;

    iterator begin() { return iterator((char*)this + sizeof(header)); }

    iterator end() { return iterator((char*)this + header.size); }

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

  private:
    class iterator
    {
      public:
        typedef OOP<VMObject> value_type;
        typedef std::ptrdiff_t difference_type;
        typedef value_type* pointer;
        typedef value_type& reference;
        typedef std::input_iterator_tag iterator_category;

        explicit iterator(char* initial_hdr)
          : current_hdr(initial_hdr)
          , current(nullptr)
        {}

        value_type operator*() { return curr(); }

        value_type operator->() { return curr(); }

        bool operator==(const iterator& other) const
        {
            return current_hdr == other.current_hdr;
        }
        bool operator!=(const iterator& other) const
        {
            return !(*this == other);
        }

        // POSTFIX
        iterator operator++(int)
        {
            iterator i = *this;
            next();
            return i;
        }

        // PREFIX
        iterator operator++()
        {
            next();
            return *this;
        }

      private:
        value_type curr()
        {
            S9_ASSERT(current_hdr != nullptr);
            if (current == nullptr) {
                current = VMObject::headerToObject(current_hdr);
            }
            return current;
        }

        void next()
        {
            value_type obj = curr();
            current = nullptr;
            current_hdr = (char*)(obj.get()) + obj->sizeInBytesAligned();
        }

        char* current_hdr;
        value_type current;
    };
};

} // namespace S9

#endif // _SEGMENT_H_
