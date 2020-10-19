/*
 * Copyright (c) 2020 Javier Pimas & LabWare
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef KERNEL_H_
#define KERNEL_H_

#include "Object.h"

/**
 * TBW...
 */
struct Kernel : Object
{
    // Module instvars
    Object* name;
    Object* version;
    Object* classes;
    Object* hash;
    Object* signature;
    Object* loadAction;

    // Kernel instvars
    Object* entrypointCode;
    Object* entrypointReceiver;
};

#endif /* KERNEL_H_ */
