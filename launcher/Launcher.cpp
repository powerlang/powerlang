/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#include "Launcher.h"
#include "ImageSegment.h"
#include "Util.h"
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
                            SmallInteger::from(argc),
                            SmallInteger::from(argv));

    if (retval->isSmallInteger()) {
    	return retval->asSmallInteger()->asNative();
    } else {
    	return 0;
    }
}

Object*
Launcher::launch(Kernel* kernel, SmallInteger* argc, SmallInteger* argv)
{
	ASSERT(kernel != nullptr);
	ASSERT(argc != nullptr);
	ASSERT(argv != nullptr);

    /*
     * First, validate kernel object
     */
    ASSERT(kernel->size() >= (sizeof(Kernel) / sizeof(HeapObject*)));


    /*
     * Finally, setup a call frame and call Smalltalk code.
     */

    Object* retvalObj = SmallInteger::from(127)->object();

#   ifdef __x86_64__
    asm (
       "push %[argc]               \n"
       "push %[argv]               \n"

       "call *%[entry]             \n"
       : "=rax" (retvalObj)
       : "rsi" (kernel->entrypointReceiver),

         [entry] "g" (kernel->entrypointCode),
         [argc] "g" (argc),
         [argv] "g" (argv)
    );
#   else
#   error "Unsupported architecture, please fix!"
#   endif

	return retvalObj;
}
