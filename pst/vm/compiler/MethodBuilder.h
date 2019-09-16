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

#include "IlValue.hpp"
#include "JitBuilder.hpp"

#include "Object.h"
#include "Classes.h"

using namespace OMR::JitBuilder;

namespace S9 {
class MethodBuilder : public OMR::JitBuilder::MethodBuilder
{
  public:
    MethodBuilder(OOP<VMMethod> method, OMR::JitBuilder::TypeDictionary* types);

    virtual IlValue* SmallInteger(intptr_t value);
    virtual IlValue* Literal(intptr_t index);

    virtual bool buildIL();

    virtual IlValue* buildNode(OOP<VMObject> node);

    virtual ~MethodBuilder() {}

  private:
    OOP<VMMethod> method;
    IlType* AddressPtr;

    IlValue* buildMethod(const OOP<VMObject> node);
    IlValue* buildReturn(const OOP<VMObject> node);
    IlValue* buildLiteral(const OOP<VMObject> node);
};
} // namespace S9

#endif /* _COMPILER_METHODBUILDER_H_ */
