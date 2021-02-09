ABI of the DMR runtime
======================



The native code of the DMR follows a series of rules that form an invariant
which must be maintained while executing managed code. An optimizing
compiler might alter those rules during moments considered atomic, but
in general the rules apply all the time.

The general design favors design simplicity as the most valued property.
Then comes performance, which should be take into account too.

Execution context
*****************

The DMR is designed as a register machine with a stack. There is a set
of abstract registers, which are mapped to concrete ones depending on
the target processor ISA:

.. csv-table:: Registers!
   :header: "Abstract name", "Concrete name (amd64)", "Type", "Description"
   :widths: 20, 20, 20, 40
   
   "IP", "RIP", "callee-saved", "Instruction Pointer"
   "SP", "RSP", "callee-saved", Stack Pointer"
   "FP", "RBP", "callee-saved", "Stack Frame Pointer"
   "R", "RAX", "volatile", "Receiver and Return value pointer"
   "M", "RBX", "callee-saved", "Method/Block native context"
   "S", "RSI", "callee-saved", "Self"
   "E", "RDI", "callee-saved", "Environment"
   "A", "RDX", "volatile", "Argument"
   "T", "RCX", "volatile", "Temporal"
   "V", "R11", "volatile", "Volatile"
   "nil", "R12", "fixed", "nil"
   "true", "R13", "fixed", "true"
   "false", "R14", "fixed", "false"
   "G", "R15", "fixed", "commonly used global objects"
  
IP (Instruction Pointer), SP (Stack Pointer), and FP (Frame Pointer) are
self describing. R register contains the Receiver at the instant at
which a message is going to be sent, and contains the Return value at the moment when
a method is about to exit. When entering a method, R register (which is volatile) is
stored into S (Self), which is callee-saved. This allows to have a pointer to self permanently
in a register while executing a method. Previous S is restored by the callee at exit,
loading it from the stack frame of the caller. M (currenty executing Method) provides
access to a method or block's
native code and literals. NativeCode objects (the ones pointed by M) know the CompiledMethod
or CompiledBlock that generated them, and the literals used within native code. They also
point to the byte array that holds the machine instructions to be used by the processor.
M is restored when returning in the same way than S. 
A, T and V register names are just denotational.
This means they were named like that because of their main uses, but they can be used
for different things. They are usually free, ready for usage. We describe the way they
work first and give some examples later.
A (Arg0) is used whenever a register is needed for fast/inline arguments,
like with inlined binary integer operations. It is not used for passing real
arguments in message sends. 
T (Temp0) is used to store temporary values during operations that require a free register.
V (Val0) is used to load constants. It is needed because typical ISAs do not let use full
64-bit constants in instructions, so to use a big constant (like a pointer) you
must first load it into some register.
Nil, true and false registers are loaded when entering from C code, and leave like
that forever (as in C they are callee-saved, it is not necessary to restore them
when calling C code).


Arguments, temporaries and environment
**************************************

Arguments are pushed into the stack from left to right. They are not passed in
registers because that would complicate the general design and also debugging.
Temporaries are stored in the stack for the same reasons. Leftmost temporary
is pushed first, which usually means it is stored at the higher addresses
(amd64). When a method has temporaries shared with child blocks, or non-local
returns, it creates an environment and pushes it (and the previous one) into
the stack before temporaries. The environment is an object of class array,
that will have as many slots as shared temporaries.

Block closures also create an environment, again of a size that is equal
to the amount of temporaries they share with their child blocks.


Native code examples
********************

.. todo:: add a couple of examples of usage of registers in native code 

.. todo:: add an example picture of the stack





