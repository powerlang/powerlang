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

VMObject*
VMObject::slot(uint32_t index)
{
    S9_ASSERT(!this->_isBytes());
    S9_ASSERT(/*index >= 0 &&*/ index <= this->_size());

    VMObject** slot = (VMObject**)this + index;

    return *slot;
}

uint8_t
VMObject::byte(uint32_t index)
{
    S9_ASSERT(this->_isBytes());
    S9_ASSERT(/*index >= 0 &&*/ index <= this->_size());
    return *(((uint8_t*)this) + index);
}

VMObject*
VMObject::headerToObject(void* header)
{
    VMObject* obj = (VMObject*)((char*)header + sizeof(pst::small_header_t));
    if (obj->behavior() == nullptr)
        obj = (VMObject*)((char*)header + sizeof(pst::large_header_t));
    return obj;
}

void
VMObject::initializeSpecialObjects(VMObject* specialObjectsArray)
{
    S9_ASSERT(specialObjectsArray->size() == 5);

    SpecialObjectsArray = specialObjectsArray;

    {
        int i = 0;

        Nil = specialObjectsArray->slot(i++);
        True = specialObjectsArray->slot(i++);
        False = specialObjectsArray->slot(i++);
        Class_SmallInteger = specialObjectsArray->slot(i++);
        Symbol_evaluate = specialObjectsArray->slot(i++);
    }
}

OOP<VMObject> SpecialObjectsArray;
OOP<VMObject> Nil;
OOP<VMObject> True;
OOP<VMObject> False;
OOP<VMObject> Class_SmallInteger;
OOP<VMObject> Symbol_evaluate;

} // namespace S9
