# Powerlang

This is Powerlang, a research vehicle to explore about implementation of programming
languages. It is a language creation toolkit, something you can use to build a new
Smalltalk implementation, or your own language of choice.
We provide tools for coding, bootstrapping, compiling, jitting and debugging the
implementation.

Power Smalltalk serves as a reference implementation using the framework.

# Power Smalltalk

This is also the main repository of Power Smalltalk, a modern Smalltalk
implementation.

Below is our humble vision of what a modern Smalltalk design
should look like, the direction in which we want to go:

- A minimal Smalltalk, running on top of a JIT-based DMR, for simplicity, security, dynamism and performance.
- Namespace-based to ease modularity.
- Windows, Linux, Mac and nopsys, on any 64-bit arch.
- Supporting both live environment development using vdb<->gdb.
- Supporting freezed-system development using specs from files, metaphysics for debugging.
- Clean repeatable bootstrap from source code, using different dialects (Pharo et al).
- Smalltalk source code is stored on git using tonel format. We store just code and
  definitions in the repository, no artifacts.
- Build artifacts go through Continuous Integration since the first commit.
- Each project is built into a (binary) image segment (`.sis` file) that loads very quickly.
- A package distribution system (ppm) shall compute dependencies and fetch prebuilt `.sis`s for
  quick setup, update and deployment.
- Each OS platform shall be in a separate project, stored in an image segment autoloaded
  at startup according to the running platform.
- Remotely debuggable through vdb<->gdb.
- Use astcodes to represent computation, a lower-level representation of asts.
- We want a fully smalltalk-written GC, but will start with compressing GC on a dll (C++)

## Power Smalltalk Build Instructions

```
git clone --recurse-submodules git@github.com:melkyades/pst.git
make
```
