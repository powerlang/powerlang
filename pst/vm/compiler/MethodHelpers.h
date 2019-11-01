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
#ifndef _COMPILER_METHODHELPERS_H_
#define _COMPILER_METHODHELPERS_H_

#include "Object.h"

namespace S9 {
class MethodHelpers
{
  public:
    static bool RequestFunction(const char* name,
                                OMR::JitBuilder::MethodBuilder* builder);

    static VMObject* LookupAndInvoke0(VMObject* obj, VMObject* sel);
    static VMObject* LookupAndInvoke1(VMObject* obj,
                                      VMObject* sel,
                                      VMObject* a1);
    static VMObject* LookupAndInvoke2(VMObject* obj,
                                      VMObject* sel,
                                      VMObject* a1,
                                      VMObject* a2);
};
} // namespace S9

#endif /* _COMPILER_METHODHELPERS_H_ */
