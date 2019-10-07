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
#include <Classes.h>

namespace S9 {

OOP<VMObject>
VMMethodDictionary::lookup(OOP<VMObject> sel)
{
    OOP<> table = this->s_table;
    S9_ASSERT((table->size() % 2) == 0);
    for (size_t i = 0; i < table->size(); i += 2) {
        if (sel == table->slot(i))
            return table->slot(i + 1);
    }
    return {};
}

OOP<VMObject>
VMBehavior::lookup(OOP<VMObject> sel)
{
    OOP<VMBehavior> behavior = this;
    while (behavior != Nil) {
        OOP<VMMethodDictionary> md = behavior->s_methods;
        OOP<> val = md->lookup(sel);
        if (val != nullptr)
            return val;
        behavior = behavior->s_next;
    }
    return {};
}

OOP<VMObject>
VMMethod::literal(OOP<VMObject> index)
{
    S9_ASSERT(index->isSmallInt());
    return literal(index->smallIntVal());
}

OOP<VMObject>
VMMethod::literal(uint32_t index)
{
    S9_ASSERT(s_literals->isPointers());
    S9_ASSERT(index <= s_literals->size());
    return s_literals->slot(index - 1);
}

} // namespace S9
