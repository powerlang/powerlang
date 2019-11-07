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

#include "Primitive.h"

#include <memory>

namespace BAST {

VMObject* Primitive::Failure = (VMObject*)(0x1 << 1);

bool
RuntimePrimitive::buildIL(MethodBuilder* bb)
{
    IlType** argTypes = new IlType*[narg + 1];
    IlValue** argValues = new IlValue*[narg + 1];

    argTypes[0] = bb->Address;
    argValues[0] = bb->ConstAddress((void*)impl);
    argValues[0 + 1] = bb->LoadSelf(bb);
    for (int i = 0; i < narg; i++) {
        argTypes[i + 1] = bb->Address;
        argValues[i + 1 + 1] = bb->LoadArg(bb, i);
    }
    bb->DefineFunction(
      name, file, line, (void*)impl, bb->Address, narg + 1, argTypes);
    bb->Return(bb->ComputedCall((char*)name, narg + 1, argValues));

    delete[] argTypes;
    delete[] argValues;
    return true;
}

extern "C" VMObject*
PrimSmallIntegerPlus(VMObject* rec, VMObject* arg)
{
#define PrimSmallIntegerPlus_LINE LINETOSTR(__LINE__)

    if (!rec->isSmallInt())
        return Primitive::Failure;
    if (!arg->isSmallInt())
        return Primitive::Failure;

    return VMObject::smallIntObj(rec->smallIntVal() + arg->smallIntVal());
}

class ImplSmallIntegerPlus : public InlinedPrimitive
{
  public:
    ImplSmallIntegerPlus(const char* name, const int narg)
      : InlinedPrimitive(name, narg)
    {}

    virtual bool buildIL(MethodBuilder* bb);
};

bool
ImplSmallIntegerPlus::buildIL(MethodBuilder* bb)
{
    IlValue* rec = bb->LoadSelf(bb);
    IlValue* arg = bb->LoadArg(bb, 0);

    IlBuilder* bothSmallInts = NULL;

    bb->IfThen(&bothSmallInts, bb->TestSmallInteger(bb, arg));
    bothSmallInts->Return(bothSmallInts->ConvertTo(
      bothSmallInts->Address,
      bothSmallInts->Add(
        bothSmallInts->And(bothSmallInts->ConvertTo(bothSmallInts->Int64, rec),
                           bothSmallInts->ConstInt64(~1)),
        bothSmallInts->ConvertTo(bothSmallInts->Int64, arg))));
    return true;
}
bool Primitives::initialized = false;

std::map<std::string, Primitive*> Primitives::map;

void
Primitives::initialize()
{
    if (initialized)
        return;

    //    add(new RuntimePrimitive("SmallIntegerPlus",
    //                             1,
    //                             PrimSmallIntegerPlus,
    //                             __FILE__,
    //                             PrimSmallIntegerPlus_LINE));
    add(new ImplSmallIntegerPlus("SmallIntegerPlus", 1));
}
} // namespace BAST
