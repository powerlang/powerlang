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
#ifndef _PRIMITIVE_H_
#define _PRIMITIVE_H_

#include <string>
#include <map>

#include "Object.h"
#include "compiler/MethodBuilder.h"

namespace S9 {

class Primitive
{
  public:
    /**
     * `Primitive::Failure` is a value returned by primitive
     * when it fails. It's value is carefully chosen so that
     * there could be no object with that very reference.
     */
    static VMObject* Failure;

    /**
     * Name of the primitive. Should be the same as name
     * of the class. Used to look it up.
     */
    const char* name;

    /**
     * Number of arguments this primitive takes (0, 1, 2, ...)
     */
    const int narg;

    Primitive(const char* name, const int narg)
      : name(name)
      , narg(narg)
    {}

    /**
     * Build IL that calls the primitive on given MethodBuilder.
     */
    virtual bool buildIL(MethodBuilder* builder) = 0;
};

class RuntimePrimitive : public Primitive
{
  public:
    /**
     * Implementation of the primitive. This should be naked
     * pointer to a function defined as
     *
     *    extern "C" VMObject* PrimSomething(VMObject* ...)
     *
     */
    const void* impl;
    /**
     * Filename in which the primitive implementation is defined.
     * Used for debugging purposes;
     */
    const char* file;

    /**
     * Line in `file` in which the primitive implementation is defined.
     * Used for debugging purposes;
     */
    const char* line;

    RuntimePrimitive(const char* name,
                     const int narg,
                     const void* impl,
                     const char* file,
                     const char* line)
      : Primitive(name, narg)
      , impl(impl)
      , file(file)
      , line(line)
    {}

    virtual bool buildIL(MethodBuilder* builder);
};

class InlinedPrimitive : public Primitive
{
  public:
    InlinedPrimitive(const char* name, const int narg)
      : Primitive(name, narg)
    {}

    virtual bool buildIL(MethodBuilder* builder) = 0;
};

class Primitives
{
  private:
    static bool initialized;

    static void initialize();

    static void add(Primitive* prim) { map[prim->name] = prim; }

    static std::map<std::string, Primitive*> map;

  public:
    static Primitive* Lookup(std::string name)
    {
        if (!initialized)
            initialize();
        return map[name];
    }
};

} // namespace S9

#endif /* _PRIMITIVE_H_ */
