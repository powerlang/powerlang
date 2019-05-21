# Power Smalltalk

This is the main Power Smalltalk repo, clone here and then execute the init script

```
git clone git@github.com:melkyades/pst.git
./scripts/init-for-bootstrapping.sh
```

to get all the others automatically loaded. Finally, to open the development environment just do:

```
cd bootstrap
./pharo-ui PST.image
```

This is Power Smalltalk. Below is our vision of what a modern Smalltalk design
should look like, the direction in which we want to go. 

`powerst` aims to be a clean, modern, minimal, modular, simple, portable, approachable
Smalltalk implementation.


- A minimal JIT-based DMR, for simplicity, security, dinamism and performance.
- Namespace-based to ease modularity.
- Windows, Linux, Mac and nopsys, on any 64-bit arch.
- Supporting both live environment development using vdb<->gdb.
- Supporting freezed-system development using specs from files, metaphysics for debugging.
- Clean repeatable bootstrap from source code, using different dialects (Pharo et al).
- Smalltalk source code is stored on git using tonel format. We store just code and
  definitions in the repo, no artifacts. One repo per project.
- Build artifacts go through Continuous Integration since the first commit.
- Each project is built into a (binary) image segment (`.sis` file) that loads very quickly.
- A package distribution system (ppm) shall compute dependencies and fetch prebuilt `.sis`s for
  quick setup, update and deployment.
- Each OS platform shall be in a separate project, stored in an image segment autoloaded
  at startup according to the running platform.
- Remotely debuggable through vdb<->gdb.
- Instead of bytecodes we use astcodes, a compact binary representation of asts.
- We want a fully smalltalk-written GC, but will start with kompressor GC on a dll (C++)

