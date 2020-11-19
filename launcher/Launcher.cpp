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
#include "Runtime.h"

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

    return launch(kernel, argc, argv);;
}

int
Launcher::launch(ImageSegment *kernel, const int argc, const char **argv)
{
	ASSERT(kernel != nullptr);

    auto runtime = (Runtime*)(void*)kernel->header.module->slot(6);
    return runtime->init(argc, argv);
}

