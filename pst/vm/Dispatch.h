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
 all
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
#ifndef _DISPATCH_H_
#define _DISPATCH_H_

#include <Classes.h>
#include <Object.h>
#include <compiler/Compiler.h>

namespace BAST {

static inline OOP<VMObject>
LookupInClass(OOP<VMBehavior> behavior, OOP<VMObject> sel)
{
    return behavior->lookup(sel);
}

static inline OOP<VMObject>
Lookup(OOP<VMObject> obj, OOP<VMObject> sel)
{
    return LookupInClass(obj->behavior(), sel);
}

template<typename... Targs>
OOP<VMObject>
LookupAndInvoke(OOP<VMObject> obj, OOP<VMObject> sel, Targs... args)
{
    printf("LookupAndInvoke(%p, %p #%s, ...)\n",
           obj.get(),
           sel.get(),
           sel.get()->stringVal().c_str());
    OOP<VMMethod> mthd = Lookup(obj, sel);

    auto code = mthd->getNativeCode();

    if (code == nullptr) {
        code = Compiler::compile(mthd);
        if (code == nullptr)
            abort();
        else
            mthd->setNativeCode(code);
    }

    return code(*obj, *sel, *args...);
}
} // namespace BAST

#endif /* _DISPATCH_H_ */
