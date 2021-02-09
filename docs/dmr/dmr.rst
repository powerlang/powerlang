DMR runtime
===========

The Dynamic Metacircular Runtime flavor of powerlang is an implementation of a runtime
that is completely self hosted. There is no other "VM", the generated image contains
everything needed to execute its code.

The SExpressions (Source Expressions) are AOT nativized, so that all
needed code can be executed and, when required, a JIT compiler can be loaded into that
image so that new code can be nativized on-the-fly.

Memory and garbage collector are written in the same language as the rest of the
system and incorporated into the bootstrapped image when building the system from
the spec.

.. toctree::
   :maxdepth: 2
   :hidden:
   
   abi

