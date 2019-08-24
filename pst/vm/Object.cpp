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

#include <Object.h>

namespace S9 {

Object*
Object::slot(uint32_t index)
{
    S9_ASSERT(!this->_isBytes());
    S9_ASSERT(/*index >= 0 &&*/ index <= this->_size());

    Object** slot = (Object**)this + index;

    return *slot;
}

uint8_t
Object::byte(uint32_t index)
{
    S9_ASSERT(this->_isBytes());
    S9_ASSERT(/*index >= 0 &&*/ index <= this->_size());
    return *(((uint8_t*)this) + index);
}

} // namespace S9
