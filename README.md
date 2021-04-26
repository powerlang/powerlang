# Powerlang

This is Powerlang, a research vehicle to explore implementations of programming
languages. While focused on Smalltalk, it aims to be a generic language creation
toolkit, something you can use to either evolve Smalltalk, or otherwise build
a new language implementation of choice.
We provide tools for coding, bootstrapping, compiling, jitting and debugging the
implementation.

Bee Smalltalk serves as a reference implementation using the framework.
We are implementing an evolution of the classic Smalltalk-80. Something
adapted to the new kinds of systems that are common these days: from
embedded to servers, with or without a gui, supporting local and remote development.
Visit [Powerlang docs](https://powerlang.readthedocs.io/en/latest/)
for documentation and [our blog](https://powerlang.github.io) for the latest news.

[![Actions Status](https://github.com/powerlang/powerlang/workflows/CI/badge.svg)](https://github.com/powerlang/powerlang/actions)
[![Documentation Status](https://readthedocs.org/projects/powerlang/badge/?version=latest)](https://powerlang.readthedocs.io/en/latest/?badge=latest)

# Building

**Note**: *following is tested on Linux, for Windows, please refer to section
"Building launcher for Windows" at the end.*

After cloning the repo, run make to create a pharo bootstrap image. This image
will contain all the tools you need to generate your new language.

```
git clone git@github.com:powerlang/powerlang.git
```

Also you will need the sources of your language, that have to be placed
in `bootstrap/specs/<your lang>`. Lets say you want to bootstrap Bee Smalltalk:

```
git clone git@github.com:powerlang/bee-dmr.git bootstrap/specs/bee-dmr
echo "bee-dmr" >bootstrap/specs/current
```

Now, just do `make`:

```
make
```

This compiles launcher executable (`bee-dmr`) and kernel image (`bee-dmr.bsl`) in
`build/<arch>-<os>` (so if you're running Linux on x86_64, it's `build/x86_64-linux`).

# Running

Assuming you have built everything as descibed above, you may run it by:

```
cd build/x86_64-linux # or other <arch>-<os> directory
./bee-dmr bee-dmr.bsl
echo $?
```
This last should echo "3" as the result of the computation.

This is because the code executed is something like
```smalltalk
"bee-dmr/Kernel/Kernel.st"
Kernel >> entry: argc argv: argv [
	<callback: long (long, pointer)>
	"^Smalltalk startSession"
	^Kernel new foo.
]

Kernel >> foo [
	| result |
	result := 42 factorial.
	^result = 0x3C1581D491B28F523C23ABDF35B689C908000000000 
		ifTrue: [1] 
		ifFalse: [0]
]
```
So the unboxed encoding of "1" is returned.

The encoding for smallIntegers is ((smallInt bitShift: 1) + 1), so (1 bitShift: 1) + 1 -> 3.


Not that this looks like much at the moment, which bring us to:

# Development

## ...in Pharo

To open Powerlang Pharo development image:

```
cd bootstrap
./pharo-ui bootstrap.image
```

All Powerlang code is in packages named `Powerlang-*`. Have fun!

## ...in Smalltalk/X

Please refer to [README_STX.md](README_STX.md) for instructions
how to load Powerlang into [Smalltalk/X jv-branch](https://swing.fit.cvut.cz/projects/stx-jv)

# Building launcher for Windows

For windows from linux (using mingw64) do:

```
cd launcher
$ cmake -B build -DCMAKE_TOOLCHAIN_FILE=toolchain-mingw64.cmake
cd build
make
```

For Windows from Windows, you will need a C++ compiler. Instructions here are for
mingw-64 (clang should also be possible). To install mingw64, follow the instructions
[here](https://code.visualstudio.com/docs/cpp/config-mingw). Make sure to install it
in a path without spaces (like C:/mingw-w64) or you may face errors. Add it to path,
in my case it was `C:\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin`.
Install CMake and be sure to have its path added too. Then do:

```
cd launcher
$ cmake -B build -G "MinGW Makefiles"
cd build
make
```

