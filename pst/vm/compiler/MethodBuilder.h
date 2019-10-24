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
#ifndef _COMPILER_METHODBUILDER_H_
#define _COMPILER_METHODBUILDER_H_

#include <memory>

#include "IlValue.hpp"
#include "JitBuilder.hpp"

#include "Object.h"
#include "Classes.h"

using namespace OMR::JitBuilder;

namespace S9 {

using IlValueA = std::unique_ptr<IlValue* []>;

class MethodBuilder : public OMR::JitBuilder::MethodBuilder
{
  public:
    MethodBuilder(OOP<VMMethod> method, OMR::JitBuilder::TypeDictionary* types);

    MethodBuilder(OOP<VMMethod> method, MethodBuilder* callerMB);

    virtual bool RequestFunction(const char* name);

    virtual bool buildIL();

    virtual ~MethodBuilder() {}

    IlValue* LoadSmallInteger(IlBuilder* bb, intptr_t value);
    IlValue* LoadLiteral(IlBuilder* bb, intptr_t index);
    IlValue* LoadSelf(IlBuilder* bb);
    IlValue* LoadArg(IlBuilder* bb, int n);
    IlValue* LoadBehavior(IlBuilder* bb, IlValue* obj);
    IlValue* LoadBehaviorNonImmediate(IlBuilder* bb, IlValue* obj);

    IlValue* TestSmallInteger(IlBuilder* bb, IlValue* obj);
    IlValue* TestBehavior(IlBuilder* bb, IlValue* obj, OOP<VMBehavior> behavior);

  private:
    OOP<VMMethod> method;
    IlType* AddressPtr;
    int labelCount = 0;

    std::string* newInternalId(std::string prefix = "label");

    IlValue* buildNode(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildMethod(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildPrimitive(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildReturn(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildLiteral(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildSend(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildVariable(IlBuilder* bb, const OOP<VMObject> node);

    IlValueA buildSendArgs(IlBuilder* bb, const OOP<VMObject> node);
    IlValue* buildSendFull(IlBuilder* bb, int numArgs, IlValueA& args);

    static const int MaxParameters;
    static const char* ParameterNames[];

    static const int MaxLocals;
    static const char* LocalNames[];
};
} // namespace S9

#endif /* _COMPILER_METHODBUILDER_H_ */
