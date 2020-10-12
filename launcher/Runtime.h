/*
 * Copyright (c) 2020 Javier Pimas
 *
 * This program and the accompanying materials are made available under
 * the terms of the MIT license, see LICENSE file.
 *
 * SPDX-License-Identifier: MIT
 */


#ifndef _RUNTIME_H_
#define _RUNTIME_H_

struct Object;

#ifdef __cplusplus 
extern "C" {
#endif

struct Runtime
{
    int (*init)(const int argc, const char **argv);
    Object* (*lookup)(const char* symbol, Object *module);
	Object* (*send)(const char *selector, Object *receiver);

};

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* _RUNTIME_H_ */
