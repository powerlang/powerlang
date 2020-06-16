/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */

#include <stdint.h>

#include "Launcher.h"
#include "ImageSegment.h"
#include "Kernel.h"

int
Launcher::main(const int argc, const char** argv)
{
    if (argc != 2) {
        printf("Usage: %s <KERNEL_SEGMENT>\n", argv[0]);
        return 1;
    }
    std::ifstream file(argv[1], std::ifstream::binary);
    if (!file) {
        printf("No such file: %s\n", argv[1]);
        return 1;
    }
    auto kernel = ImageSegment::load(&file);

    auto retval = launch((Kernel*)kernel->header.module,
                            Object::smallIntObj(argc),
                            Object::smallPtrObj(argv));

    if (retval->isSmallInt()) {
    	return retval->smallIntVal();
    } else {
    	return 0;
    }
}

Object*
Launcher::launch(Kernel* kernel, Object* argc, Object* argv)
{
	ASSERT(kernel != nullptr);
	ASSERT(argc != nullptr);
	ASSERT(argv != nullptr);

    /*
     * First, validate kernel object
     */
    ASSERT(kernel->size() >= (sizeof(Kernel) / sizeof(Object*)));


    /*
     * Finally, setup a call frame and call Smalltalk code.
     */

    Object* retvalObj = Object::smallIntObj(127);

#   ifdef __x86_64__
    asm (
       "mov  %[nilObj], %%r12      \n"
       "mov  %[trueObj], %%r13     \n"
       "mov  %[falseObj], %%r14    \n"

       "push %[argc]               \n"
       "push %[argv]               \n"

       "call *%[entry]             \n"
       : "=rax" (retvalObj)
       : "rsi" (kernel->entryPointReceiver),

         [entry] "g" (kernel->entryPointCode),
         [argc] "g" (argc),
         [argv] "g" (argv),

         /*
          * Sadly, we GCC does not allow one to specify 
          * r8..r15 in register constraints, so we have to
          * initialize by explicit mov from wherever GCC
          * fancy to place the values. Sigh. 
          */
         [nilObj] "g" (kernel->nilObj),
         [trueObj] "g" (kernel->trueObj),
         [falseObj] "g" (kernel->falseObj)
       : "r12", "r13", "r14"
    );
#   else
#   error "Unsupported architecture, please fix!"
#   endif

	return retvalObj;
}
