Powertalk 
=========

.. |ss| raw:: html

   <strike>

.. |se| raw:: html

   </strike>


Powertalk is a Smalltalk-like system with late-bound names for improved modularity.
The main difference is that resolving names dynamically allows for features that
are more difficult to implement in traditional Smalltalk-80 systems.

*this is a work in progress documentation, the code in the repos might not yet match
what is described hereby*

1. Namespaces
#############

A namespace is an object that maps symbols to objects. In the original ST-80, the
only "namespace" was Smalltalk object, whereas in Powertalk different contexts use
different namespaces, which allow for the coexistance of independent libraries
without the names of one interfering with the names of the other.


2.  Modules
###########

The main kind of namespaces are modules. A module is a conceptual unit that defines
a namespace, a series of dependencies, imported names, classes with methods and 
extension methods. As names defined in a module do not interfere with names defined
in other module, the symbols of each module's namespace are more tightly coupled than
in say Smalltalk dictionary. For that reason, and to simplify, Powertalk classes
do not use class variables: i.e. instead of having a SecondsPerMinute in the Timestamp
class, you have SecondsPerMinute in the Kernel::Time module.

Powertalk allows class methods, but does not have metaclasses. Instead, it adds
class methods as instance methods of the classes. 

A similar approach can be taken to remove class methods, and metaclasses altogether,
by replacing them with module methods: instead of defining :code:`Time>>#current`
we define :code:`Time>>#currentTime` (Time corresponds to the module not the class).



1. Module Methods *(heavily WIP)*
------------------------------------


Powertalk allows modules to define a kind of extension methods. These methods are
added to the method dictionary of the class being extended, but are bound to the
module in which they are defined. 
The extension methods are accessible only with special syntax, by code that previously
imported the module of the extension method.

For example, :code:`anObject js::asJson` sends :code:`asJson` to :code:`anObject`
filtering lookup through :code:`js` module. :code:`anObject asJson` results in a
:code:`doesNotUnderstand` (unless :code:`asJson` was also defined in the class of :code:`anObject`).

Extensions methods could allow for some interesting features not available in ST-80.
In Powertalk, reflection could be implemented in terms of extension methods. To access
the class of an object, you will need to import :code:`meta` module, and then
send ``anObject meta::class``. :: 

    aRemoteArray meta::class   -> RemoteObject
    aRemoteArray remote::class -> Array

As ``meta`` is not just a symbol but actually a late-bound variable name, it is possible
to make the module itself be dynamic (for example, fetching the module that implements
``class`` from a factory: ::

    module := factory metaModule. "will return some module object like 'meta' or 'remote'"
    aRemoteArray module::class    "will send class to the module variable"

This could be used to implement some form of safety: as reflection is accessible
through extension methods, accessing metaobjects could be disabled by prohibiting
access to :code:`meta` module (and to unsafe modules that could leak metaobjects).

It can also be used to stratify runtime implementation level and application level: ::

    anObject vm::isSmallInteger
	
works as a barrier that can be implemented differently by different virtual machine
implementations. 

However, mixing dynamic lookup and primitive-like behavior might not
work well (doesn't ``vm`` lookup cause an infinite recursion? should a JIT lookup ``vm``
or ``isSmallInteger`` statically? is ``vm::isSmallInteger`` atomic in any sense?).


.. toctree::
   :maxdepth: 2
   :hidden:
   

