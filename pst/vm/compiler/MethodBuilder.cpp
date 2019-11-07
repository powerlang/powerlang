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

#include <memory>
#include <Primitive.h>
#include "Object.h"
#include "Dispatch.h"
#include "AstNodeTypes.h"
#include "AstBindingTypes.h"
#include "compiler/MethodBuilder.h"
#include "compiler/MethodHelpers.h"

namespace BAST {

const int MethodBuilder::MaxParameters = 8;
const char* MethodBuilder::ParameterNames[] = { "Arg1", "Arg2", "Arg3", "Arg4",
                                                "Arg5", "Arg6", "Arg7", "Arg8" };

const int MethodBuilder::MaxLocals = 8;
const char* MethodBuilder::LocalNames[] = { "Temp1", "Temp2", "Temp3", "Temp4",
                                            "Temp5", "Temp6", "Temp7", "Temp8" };

MethodBuilder::MethodBuilder(OOP<VMMethod> method,
                             OMR::JitBuilder::TypeDictionary* types)
  : OMR::JitBuilder::MethodBuilder(types,
                                   (OMR::JitBuilder::VirtualMachineState*)NULL)
  , method(method)
{
    // CRAP CRAP CRAP: this is bogus, we need to construct proper name,
    // number of arguments and so on...
    DefineName((new std::string(method->s_selector->stringVal()))->c_str());

    DefineReturnType(Address);
    DefineParameter("self", Address);
    DefineParameter("__sel", Address);
    for (uint32_t i = 0; i < method->getNumberOfArgs(); i++) {
        DefineParameter(ParameterNames[i], Address);
    }

    AddressPtr = types->PointerTo(Address);
}

MethodBuilder::MethodBuilder(OOP<VMMethod> method, MethodBuilder* callerMB)
  : OMR::JitBuilder::MethodBuilder(callerMB)
  , method(method)

{
    // CRAP CRAP CRAP: the below code is copy-paste of above.
    DefineName((new std::string(method->s_selector->stringVal()))->c_str());

    DefineReturnType(Address);
    DefineParameter("self", Address);
    DefineParameter("__sel", Address);
    for (uint32_t i = 0; i < method->getNumberOfArgs(); i++) {
        DefineParameter(ParameterNames[i], Address);
    }

    AddressPtr = callerMB->AddressPtr;
}

bool
MethodBuilder::RequestFunction(const char* name)
{
    return MethodHelpers::RequestFunction(name, this);
}

IlValue*
MethodBuilder::LoadSmallInteger(IlBuilder* bb, intptr_t value)
{
    return bb->ConstAddress(VMObject::smallIntObj(value));
}

IlValue*
MethodBuilder::LoadLiteral(IlBuilder* bb, intptr_t index)
{
    BAST_ASSERT((size_t)index < method->s_literals->size());
    IlType* AddressPtr = bb->typeDictionary()->PointerTo(bb->Address);
    return bb->LoadAt(AddressPtr,
                      bb->IndexAt(AddressPtr,
                                  bb->ConstAddress(method->s_literals),
                                  bb->Const(index)));
}

IlValue*
MethodBuilder::LoadSelf(IlBuilder* bb)
{
    return bb->Load("self");
}

IlValue*
MethodBuilder::LoadArg(IlBuilder* bb, int n)
{
    return bb->Load(MethodBuilder::ParameterNames[n]);
}

IlValue*
MethodBuilder::LoadBehavior(IlBuilder* bb, IlValue* obj)
{
    BAST_ASSERT(obj != nullptr);

    std::string* behaviorId = newInternalId("behavior");
    IlBuilder* smicase = nullptr;
    IlBuilder* objcase = nullptr;
    bb->IfThenElse(&smicase, &objcase, TestSmallInteger(bb, obj));
    {
        IlValue* behavior =
          smicase->ConstAddress((void*)Class_SmallInteger.get());
        smicase->Store(behaviorId->c_str(), behavior);
    }
    {
        objcase->Store(behaviorId->c_str(), LoadBehaviorNonImmediate(bb, obj));
    }
    return bb->Load(behaviorId->c_str());
}

IlValue*
MethodBuilder::LoadBehaviorNonImmediate(IlBuilder* bb, IlValue* obj)
{
    IlValue* behaviorBits =
      bb->LoadAt(AddressPtr, bb->Sub(obj, bb->ConstInt32(4)));
    if (VMObject::compressedReferenceBase) {
        return bb->Add(
          bb->ConstAddress((void*)VMObject::compressedReferenceBase),
          behaviorBits);
    } else {
        return behaviorBits;
    }
}

IlValue*
MethodBuilder::TestSmallInteger(IlBuilder* bb, IlValue* obj)
{
    return bb->And(bb->ConvertTo(bb->Int64, obj), bb->ConstInt64(1));
}

IlValue*
MethodBuilder::TestBehavior(IlBuilder* bb,
                            IlValue* obj,
                            OOP<VMBehavior> behavior)
{
    if (behavior == Class_SmallInteger) {
        return TestSmallInteger(bb, obj);
    } else {
        return bb->EqualTo(LoadBehavior(bb, obj),
                           bb->ConstAddress((void*)behavior.get()));
    }
}

std::string*
MethodBuilder::newInternalId(std::string prefix)
{
    return new std::string(format("%s%d", prefix.c_str(), labelCount++));
}

bool
MethodBuilder::buildIL()
{
    buildNode(this, method->s_bytecodes);
    OOP<VMObject> last =
      method->s_bytecodes->slot(method->s_bytecodes->size() - 1);
    BAST_ASSERT(last->slot(0)->isSmallInt());
    if (last->slot(0)->smallIntVal() != ReturnId) {
        Return(LoadSelf(this));
    }
    return true;
}

IlValue*
MethodBuilder::buildMethod(IlBuilder* bb, const OOP<VMObject> node)
{
    BAST_ASSERT(bb == this);
    for (size_t i = 1; i < /*2*/ node->size() /**/; i++) {
        buildNode(bb, node->slot(i));
    }
    return nullptr;
}

IlValue*
MethodBuilder::buildReturn(IlBuilder* bb, const OOP<VMObject> node)
{
    bb->Return(buildNode(bb, node->slot(2)));
    return nullptr;
}

IlValue*
MethodBuilder::buildLiteral(IlBuilder* bb, const OOP<VMObject> node)
{
    BAST_ASSERT(node->slot(1)->isSmallInt());
    intptr_t literalIndex = node->slot(1)->smallIntVal();
    if (literalIndex == 0) {
        BAST_ASSERT(node->size() == 3);
        BAST_ASSERT(node->slot(2)->isSmallInt());
        return LoadSmallInteger(bb, node->slot(2)->smallIntVal());
    } else {
        return LoadLiteral(bb, literalIndex - 1);
    }
}

IlValueA
MethodBuilder::buildSendArgs(IlBuilder* bb, const OOP<VMObject> node)
{
    IlValueA args(new IlValue*[node->size() - 1]);
    args[0] = buildNode(bb, node->slot(2));                      // receiver
    args[1] = LoadLiteral(bb, node->slot(1)->smallIntVal() - 1); // selector
    for (size_t i = 3; i < node->size(); i++) {
        args[i - 1] = buildNode(bb, node->slot(i));
    }
    return args;
}

IlValue*
MethodBuilder::buildSendFull(IlBuilder* bb, int numArgs, IlValueA& args)
{
    BAST_ASSERT(numArgs >= 2);

    IlValue* funcAndArgs[numArgs + 1];
    for (int i = 0; i < numArgs; i++) {
        funcAndArgs[i + 1] = args[i];
    }

    switch (numArgs) {
        case 2:
            funcAndArgs[0] =
              bb->ConstAddress((void*)&MethodHelpers::LookupAndInvoke0);
            return bb->ComputedCall(
              (char*)"LookupAndInvoke0", numArgs + 1, funcAndArgs);
        case 3:
            funcAndArgs[0] =
              bb->ConstAddress((void*)&MethodHelpers::LookupAndInvoke1);
            return bb->ComputedCall(
              (char*)"LookupAndInvoke1", numArgs + 1, funcAndArgs);
        case 4:
            funcAndArgs[0] =
              bb->ConstAddress((void*)&MethodHelpers::LookupAndInvoke2);
            return bb->ComputedCall(
              (char*)"LookupAndInvoke2", numArgs + 1, funcAndArgs);
        default:
            BAST_ASSERT(0 && "Not yet supported");
    }
    return nullptr;
}

OOP<VMObject>
assumedBehaviorOfSend(OOP<VMObject> selector)
{
    BAST_ASSERT(selector->isBytes());
    if (selector->stringVal() == "+") {
        return Class_SmallInteger;
    }
    return nullptr;
}

IlValue*
MethodBuilder::buildSend(IlBuilder* bb, const OOP<VMObject> node)
{
    BAST_ASSERT(node->slot(1)->isSmallInt());

    OOP<VMObject> selector = method->literal(node->slot(1));
    OOP<VMObject> behavior = assumedBehaviorOfSend(selector);
    IlValueA args = buildSendArgs(bb, node);
    if (behavior != nullptr) {
        OOP<VMMethod> callee = LookupInClass(behavior, selector);
        // Avoid recursive inlining into itself
        if (callee != method) {

            std::string* sendId = newInternalId("send");

            IlBuilder* fastpath = nullptr;
            IlBuilder* fallback = nullptr;

            DefineLocal(sendId->c_str(), Address);

            bb->IfThenElse(
              &fastpath, &fallback, TestBehavior(bb, args[0], behavior));
            {
                BAST_ASSERT(callee != nullptr);
                /*
                 * CRAP CRAP CRAP
                 *
                 * Here we leak a reference...
                 */
                MethodBuilder* calleeBuilder = new MethodBuilder(callee, this);
                fastpath->Store(
                  sendId->c_str(),
                  fastpath->Call(calleeBuilder, node->size() - 1, args.get()));
            }
            {
                fallback->Store(sendId->c_str(),
                                buildSendFull(fallback, node->size() - 1, args));
            }
            return bb->Load(sendId->c_str());
        }
    }
    return buildSendFull(bb, node->size() - 1, args);

    BAST_ASSERT(0 && "Should never be reached");
    return nullptr;
}

IlValue*
MethodBuilder::buildPrimitive(IlBuilder* bb, const OOP<VMObject> node)
{
    BAST_ASSERT(bb == this);
    BAST_ASSERT(node->size() == 2);
    BAST_ASSERT(node->slot(1)->isSmallInt());

    Primitive* prim =
      Primitives::Lookup(method->literal(node->slot(1))->stringVal());
    BAST_ASSERT(prim != nullptr);

    BAST_ASSERT(prim->buildIL(this) == true);
    return nullptr;
}

IlValue*
MethodBuilder::buildVariable(IlBuilder* bb, const OOP<VMObject> node)
{
    BAST_ASSERT(node->size() >= 2);
    BAST_ASSERT(node->slot(1)->isSmallInt());

    switch (node->slot(1)->smallIntVal()) {
        case SelfId:
            return LoadSelf(bb);
        case ArgumentId:
            BAST_ASSERT(node->size() == 4);
            BAST_ASSERT(node->slot(2)->isSmallInt());
            BAST_ASSERT(node->slot(3)->isSmallInt());
            BAST_ASSERT(node->slot(3)->smallIntVal() == 0);
            return LoadArg(bb, node->slot(2)->smallIntVal() - 1);
        default:
            BAST_ASSERT(0 && "Unsupported variable type");
            return nullptr;
    }
}

IlValue*
MethodBuilder::buildNode(IlBuilder* bb, OOP<VMObject> node)
{
    BAST_ASSERT(node->isPointers());
    BAST_ASSERT(node->slot(0)->isSmallInt());

    OOP<VMObject> nodeType = node->slot(0);

    switch (nodeType->smallIntVal()) {
        case PrimitiveId:
            return buildPrimitive(bb, node);
        case MessageId:
            return buildSend(bb, node);
        case MethodId:
            return buildMethod(bb, node);
        case LiteralId:
            return buildLiteral(bb, node);
        case ReturnId:
            return buildReturn(bb, node);
        case IdentifierId:
            return buildVariable(bb, node);
        default:
            BAST_ASSERT(0 && "Unsupported nodeType");
            return nullptr;
    }
}

} // namespace BAST
