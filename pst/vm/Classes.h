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

#ifndef _CLASSES_H_
#define _CLASSES_H_

#include <cstdint>
#include <Object.h>

typedef BAST::VMObject VMObject;
#define DEFINE_CLASS(CLASSNAME, SUPERNAME, SLOTS)                               \
    namespace pst {                                                             \
    struct CLASSNAME : public SUPERNAME                                         \
    {                                                                           \
        SLOTS                                                                   \
    };                                                                          \
    }
#define DEFINE_SLOT(SLOTNAME) VMObject* s_##SLOTNAME;
#define NIL VMObject

#include "Classes.def"
#undef DEFINE_CLASS
#undef DEFINE_SLOT
#undef NIL

namespace BAST {

class VMMethodDictionary : public pst::MethodDictionary
{
  public:
    OOP<VMObject> lookup(OOP<VMObject> sel);
};

class VMBehavior : public pst::Behavior
{
  public:
    OOP<VMObject> lookup(OOP<VMObject> sel);
};

using VMNativeCodePtr = VMObject* (*)(VMObject*, ...);

class VMMethod : public pst::CompiledMethod
{
  public:
    enum Flags
    {
        NumArgs = 0x3F // or 0xFF?
    };

    VMNativeCodePtr getNativeCode()
    {
        BAST_ASSERT((this->s_nativeCode->isSmallInt()) &&
                  "Native code is not a SmallInteger");
        uintptr_t code = (uintptr_t)this->s_nativeCode;
        return (VMNativeCodePtr)(code & ~1);
    }

    void setNativeCode(VMNativeCodePtr nativeCode)
    {
        uintptr_t code = (uintptr_t)nativeCode;
        BAST_ASSERT(((code & 1) == 0) &&
                  "Native code pointer is not aligned to 2 bytes!");
        this->s_nativeCode = (VMObject*)(code | 1);
    }

    uint32_t getNumberOfArgs()
    {
        BAST_ASSERT(this->s_format->isSmallInt());
        return this->s_format->smallIntVal() & NumArgs;
    }

    /**
     * Return a literal at given `index`. Index starts
     * with 1, like in Smalltalk. `index` must be a
     * SmallInteger object.
     */
    OOP<VMObject> literal(OOP<VMObject> index);

    /**
     * Return a literal at given `index`. Index starts
     * with 1, like in Smalltalk.
     */
    OOP<VMObject> literal(uint32_t index);
};

} // namespace BAST

#endif /* CLASSES_H_ */
