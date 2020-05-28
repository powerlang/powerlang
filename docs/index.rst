
Welcome to Powerlang's documentation!
=====================================

Powerlang is a research vehicle to explore about implementation of programming
laguages. While focused on Smalltalk, it aims to be a generic language creation
toolkit, something you can use to either evolve Smalltalk, or either build
a new language implementation of choice.
We provide tools for coding, bootstrapping, compiling, jitting and debugging the
implementation.

Bee Smalltalk serves as a reference implementation using the framework.
We are implementing an evolution of the classic Smalltalk-80. Something
adapted to the new kinds of systems that are common these days: from
embedded to servers, with or without a gui, supporting remote development
from scratch. 

Setup
*****

To setup the development repository, see the instructions in 
`Powerlang repo <github.com/powerlang/powerlang>`_.

Design
******

Below is our humble vision of what a modern Smalltalk design
should look like, the direction in which we want to go.

We want a minimal modular Smalltalk, that starts from a little kernel and that
can load other modules on-the-fly to grow exactly as needed.
It should work Windows, Linux, Mac, Android and nopsys, including embedded
platforms.
64 and 32 bit architectures are the starting point, but if possible we may try
even smaller.
The bootstrap process is done mostly from a specification (source code), using
different dialects (Pharo et al). This allows freezed-system development which
is required when doing big or complex changes, specially in design. Of course,
the live environment development will be supported as usual in Smalltalk-80
systems.
Namespaces are supported from the beginning and form the base of packages.
Packages are built into (binary) image segments, that load very quickly.
A package distribution system shall compute dependencies and fetch
prebuilt image segments for quick setup, update and deployment.

Implementation
**************

At least two runtimes are being developed in parallel. The pure DMR (dynamic
metacircular runtime), and the `Eclipse OMR <https://www.eclipse.org/omr/>`_.
The DMR is an AOT-based approach, that uses Smalltalk to pre-nativize a Smalltalk
JIT compiler, and then uses that compiler to nativize on the fly other
Smalltalk code. The OMR is a state-of-the-art C++ runtime engine, that includes
plugabble interpreters, JIT-compilers and garbage collectors, which can be
used to support languages like Smalltalk.

We use astcodes to represent computation, a lower-level representation of
asts that is encoded into byte arrays.

Smalltalk source code is stored on git, using a tonel-like format. We store 
just code and definitions in the repo, no artifacts.
Build artifacts go through Continuous Integration since the very beginning.
Each OS platform is put in separate namespaces, and built into separate
image segments, which are autoloaded according at startup according to the
running platform.
The system can be debugged remotely through a vdb/gdb connection, which
allows both local and remote debugging.



Indices and tables
==================

.. toctree::
   :maxdepth: 2
   :includehidden:
   
   dmr/dmr
..   :caption: Contents:

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

Things to do (PRs are welcome!)
===============================

.. todolist::


