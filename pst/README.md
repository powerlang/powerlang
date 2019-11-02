# Power Smalltalk

## Compiling

 1. Drop Smalltalk kernel package (so called *SKernel*) into `kernel` directory. Unfortunately, we cannot provide it as of now - you need to get it somehow.

 2. Compile everything by `make`.

 This should create `kernel.bsl`, bunch of `mintest*.bsl`s and compile *native VM* (aka *C++ black magic*). The native VM itself should be in `vm/build/<arch>-<os>/s9`.

## Running

To run some `.bsl` with native VM, pass the `.bsl` as parameter, like: 

```
./vm/build/x86_64-linux/s9 mintest_3_plus_4_d.bsl
```