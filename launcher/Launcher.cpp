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
    auto kernel = load(file);

    auto retval = launch(kernel, Object::smallIntObj(argc), Object::smallPtrObj(argv));

    if (retval->isSmallInt()) {
    	return retval->smallIntVal();
    } else {
    	return 0;
    }
}

ImageSegment*
Launcher::load(std::ifstream &data)
{
	return ImageSegment::load(&data);
}

Object*
Launcher::launch(ImageSegment* kernel, Object* argc, Object* argv)
{
	ASSERT(kernel != nullptr);
	ASSERT(argc != nullptr);
	ASSERT(argv != nullptr);

	/*
	 * Now, what to do here? How to reach an entry point's native code and
	 * set up caller frame?
	 */
    //
	// ASSERT(false && "What to do here?");
    //
    // auto entry = kernel->header.module->slot(5 /* or whatever the slot index of entrypoint is at the moment*/);

	return Object::smallIntObj(42);
}
