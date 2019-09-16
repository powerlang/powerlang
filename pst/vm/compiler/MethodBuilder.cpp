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

#include "Object.h"
#include "AstNodeTypes.h"
#include "compiler/MethodBuilder.h"

namespace S9 {

MethodBuilder::MethodBuilder(OOP<VMMethod> method,
                             OMR::JitBuilder::TypeDictionary* types)
  : OMR::JitBuilder::MethodBuilder(types,
                                   (OMR::JitBuilder::VirtualMachineState*)NULL)
  , method(method)
{
    // CRAP CRAP CRAP: this is bogus, we need to construct proper name,
    // number of arguments and so on...
    DefineName("method");
    DefineParameter("self", Address);
    DefineReturnType(Address);

    AddressPtr = types->PointerTo(Address);
}

IlValue*
MethodBuilder::SmallInteger(intptr_t value)
{
    return ConstAddress(VMObject::smallIntObj(value));
}

IlValue*
MethodBuilder::Literal(intptr_t index)
{
    S9_ASSERT((size_t)index < method->s_literals->size());
    return LoadAt(
      AddressPtr,
      IndexAt(AddressPtr, ConstAddress(method->s_literals), Const(index)));
}

bool
MethodBuilder::buildIL()
{
    buildNode(method->s_bytecodes);
    return true;
}

IlValue*
MethodBuilder::buildMethod(const OOP<VMObject> node)
{
    return buildNode(node->slot(1));
}

IlValue*
MethodBuilder::buildReturn(const OOP<VMObject> node)
{
    Return(buildNode(node->slot(2)));
    return nullptr;
}

IlValue*
MethodBuilder::buildLiteral(const OOP<VMObject> node)
{
    S9_ASSERT(node->slot(1)->isSmallInt());
    intptr_t literalIndex = node->slot(1)->smallIntVal();
    if (literalIndex == 0) {
        S9_ASSERT(node->size() == 3);
        S9_ASSERT(node->slot(2)->isSmallInt());
        return SmallInteger(node->slot(2)->smallIntVal());
    } else {
        return Literal(literalIndex - 1);
    }
}

IlValue*
MethodBuilder::buildNode(OOP<VMObject> node)
{
    OOP<VMObject> nodeType = node->slot(0);
    S9_ASSERT(nodeType->isSmallInt());
    intptr_t nodeTypeId = nodeType->smallIntVal();
    switch (nodeTypeId) {
        case MethodId:
            return buildMethod(node);
        case LiteralId:
            return buildLiteral(node);
        case ReturnId:
            return buildReturn(node);
        default:
            S9_ASSERT(0 && "Unsupported nodeType");
            return nullptr;
    }
}

} // namespace S9
