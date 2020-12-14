Bootstrap 
=========

.. |ss| raw:: html

   <strike>

.. |se| raw:: html

   </strike>


Powerlang is the base system used to generate Smalltalk images from Smalltalk source
code written in files. We expect it to let generate images for other languages in the
future.

For now, Powerlang runs on top of Pharo, and consists of a set of packages that
allow to load code definitions, to compile them, to build image segments and to
generate native code for methods ahead of time, which is required when targetting
the DMR runtime.

Code is loaded into a `Ring2` environment, which is as a set of objects that
specify what is included in a module. Currently, the main supported code-base is
that of Bee Smalltalk. Powerlang has been developed hand-in-hand with Bee, with
the hope that in the future other systems are also supported. The Bee code is in
a separate git repository, which the makefiles automatically clone into
`bootstrap/specs/bee-dmr`.

Bee consists of a main `Kernel` module, which is self-hosted. This means that
the kernel is able to perform basic Smalltalk computation without accessing nor
requiring other modules. This includes objects like numbers, collections,
classes, methods and modules. If other things are to be used, they are loaded
in a modular fashion: OS support, JIT compiler, libraries are out by default
but a dependency tracking system |ss| allows |se| will allow to easily add
stuff.

Bootstrap steps
###############

Generating an executable image segment requires a series of steps, which we
describe next. You can also study these steps by looking at `Powerlang-Building`
packages. The process is the following:

1. Kernel Genesis
----------

:code:`VirtualSmalltalkImage fromSpec wordSize: n; genesis` instantiates a
virtual image that reads Bee `Kernel` module definition, and then builds
the objects required for the classes, metaclasses and behaviors.
Objects generated during the genesis are of type :code:`ObjectMap`.
This hierarchy of types allows to represent the contents of the
newly created object slots, and their corresponding spec type and
associated behavior and hash. The objects created by this virtual image
are the minimum needed to do any kind of Smalltalk execution. However,
it doesn't contain any method, as compiling methods is a more complex
step that requires bootstrap initialization of globals, class vars and
pool vars. It doesn't even contain the Smalltalk object, which is
generated later.

2. Bootstrap duality
--------------------

Initialization of globals and pools is done through execution of Smalltalk
code within the virtual image, and for that we use a
:code:`VirtualSmalltalkRuntime`. 

However, compiling methods during the bootstrap is more complex than compiling
for the current image. The compiler runs on top of the current image, and 
generates `SCompiledMethods` with literals, which can be integers, symbols, arrays,
`SCompiledBlocks`, etc. Those methods and their referenced objects need to be
converted to `ObjectMaps`, and end in the bootstrapped world. 
On the other hand, when the compiler builds methods from source, it may need to access
things living in the bootstrapped image. For example, if the compiler finds
the sting :code:`Array`, it should generate a method with a literal frame that contains
the association #Array -> Array, that belongs to the bootstrapped world.

There is a constant sense of duality while compiling and executing virtually:
objects need to be passed back and forth from the local image to the bootstrapped
image and vice-versa many times.  To deal with this, the method compiler is
passed `VirtualClasses`, which account for both the Ring specs and the `ObjectMap`
that represents the class in the bootstrapped system. To allow usage of globals and
pools or class vars, the compiler the compiler uses `VirtualDictionaries`, which know
both their keys as symbols in the local image and also the associations and values
that live in the botstrapped image.

3. Bootstrap initialization
---------------------------

After compilation, generated SCompiledMethods have references to both objects in the
current image and objects in the bootstrapped image.

And there's yet one last twist: pool dictionaries.
Pool dictionaries are more dynamic than class variables. While
class variables are all determined beforehand (in class definition), pool variables
are defined after some initialization: class variables that point to objects of type
:code:`PoolDictionary` are recognized by the compiler, and are used as local pools by
it. Before it is possible to compile arbitrary methods, the builder has to initialize
pool dictionaries. To do so, it virtualy sends the message 
:code:`#bootstrap` to the module object corresponding
to the module spec being built. The virtual runtime interprets the message send, 
creating more `ObjectMaps`. During that process the compiler
doesn't yet recognize pool variables, so pool vars can't be used to initialize pool vars
(it shouldn't be a big limitation though). One extra step is done by the bootstrapper:
it sends :code:`declareGlobals` to de module, so that any global object name is put
into the module namespace.

After this initial pass, arbitrary methods can be compiled, so the bootstrap process
creates the method dictionaries of the classes and fills them. Finally, a last
initialization pass is done by sending :code:`initialize` to the module, which can
execute more complex initialization code.

3. Module nativization
----------------------

This step shall be optional (only required by the DMR for a reduced set of modules).
The compiler in the local image generated instances of :code:`SCompiledMethod` which contain
s-expressions. An SExpressionNativizer traverses them and generates native code for
each method and block. The result of this is stored in their `nativeCode` ivar and
then transferred into the image segment being built. Kernel nativization for the DMR
also requires some extra steps, such as the nativization of invoke, lookup, and write
barrier procedures.

4. Image segment wrap-up
------------------------

During all the bootstrap process all important objects are created by the builder.
To finally generate an image segment, the builder creates an :code:`ImageSegmentWriter`
and passes it the roots, an ordered list of objects from where it will calculate what
are the objects to be included in the file.
This step writes the objects put into a binary stream
with a particular format that can be loaded by a launcher written in C++. The launcher
is in `/launcher` directory. The writer is specified a base address at which the file
should be loaded in memory, and knows how to encode each object oop according to that
address.

.. toctree::
   :maxdepth: 2
   :hidden:
   

