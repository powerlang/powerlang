/*
 * Copyright (c) 2019 Javier Pimas, Jan Vrany

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

#include "JitBuilder.hpp"
#include "compiler/MethodBuilder.h"
#include "compiler/Compiler.h"

namespace S9 {

bool Compiler::initialized = false;

OMR::JitBuilder::TypeDictionary* Compiler::types = nullptr;

bool
Compiler::initialize()
{
    ASSERT(!initialized && "Compiler already initialized!");
    initialized = initializeJit();
    types = new OMR::JitBuilder::TypeDictionary();
    return initialized;
}

VMNativeCodePtr
Compiler::compile(OOP<VMMethod> method)
{
    ASSERT(initialized && "Compiler not yet initialized!");
    MethodBuilder mb(method, Compiler::types);
    void* entry = 0;
    if (compileMethodBuilder(&mb, &entry) != 0) {
        throw "Failed to compile method";
    }
    return (VMNativeCodePtr)entry;
}

} // namespace S9
