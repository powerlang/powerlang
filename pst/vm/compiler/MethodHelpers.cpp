/*
 * Copyright (c) 2019 Javier Pimas, Boris Shingarov, Jan Vrany

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <cstring>
#include <JitBuilder.hpp>
#include "Dispatch.h"
#include "compiler/MethodHelpers.h"

namespace BAST {

VMObject*
MethodHelpers::LookupAndInvoke0(VMObject* obj, VMObject* sel)
{
#define LOOKUPANDINVOKE0_LINE LINETOSTR(__LINE__)
    return *(LookupAndInvoke<>(obj, sel));
}

VMObject*
MethodHelpers::LookupAndInvoke1(VMObject* obj, VMObject* sel, VMObject* a1)
{
#define LOOKUPANDINVOKE1_LINE LINETOSTR(__LINE__)
    return *(LookupAndInvoke<OOP<VMObject>>(obj, sel, a1));
}

VMObject*
MethodHelpers::LookupAndInvoke2(VMObject* obj,
                                VMObject* sel,
                                VMObject* a1,
                                VMObject* a2)
{
#define LOOKUPANDINVOKE2_LINE LINETOSTR(__LINE__)
    return *(LookupAndInvoke<OOP<VMObject>, OOP<VMObject>>(obj, sel, a1, a2));
}

bool
MethodHelpers::RequestFunction(const char* name,
                               OMR::JitBuilder::MethodBuilder* builder)
{
    if (strcmp(name, "LookupAndInvoke0") == 0) {
        builder->DefineFunction(name,
                                __FILE__,
                                LOOKUPANDINVOKE0_LINE,
                                (void*)&LookupAndInvoke0,
                                builder->Address,
                                2,
                                builder->Address,
                                builder->Address);
        return true;
    }
    if (strcmp(name, "LookupAndInvoke1") == 0) {
        builder->DefineFunction(name,
                                __FILE__,
                                LOOKUPANDINVOKE1_LINE,
                                (void*)&LookupAndInvoke1,
                                builder->Address,
                                3,
                                builder->Address,
                                builder->Address,
                                builder->Address);
        return true;
    }
    if (strcmp(name, "LookupAndInvoke2") == 0) {
        builder->DefineFunction(name,
                                __FILE__,
                                LOOKUPANDINVOKE2_LINE,
                                (void*)&LookupAndInvoke2,
                                builder->Address,
                                4,
                                builder->Address,
                                builder->Address,
                                builder->Address,
                                builder->Address);
        return true;
    }

    return false;
}

} // namespace BAST
