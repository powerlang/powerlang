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

# Quick setup

After cloning the repo, run make to create a pharo bootstrap image. This image
will contain all the tools you need to generate your new language. 

```
git clone git@github.com:powerlang/powerlang.git
cd powerlang
make -C bootstrap
```

Additionaly, you will need the sources of your language, that have to be placed
in `bootstrap/specs/<your lang>`. Lets say you want to bootstrap Bee Smalltalk:

```
git clone git@github.com:powerlang/bee-dmr.git bootstrap/specs/bee-dmr
echo "bee-dmr" >bootstrap/specs/current
```

You are ready, you can start working with your language now. To open the
development environment just do:

```
cd bootstrap
./pharo-ui bootstrap.image
```

You will find everything in Powerlang-* packages

# Launching

First you have to build the image launcher. For that make sure you have a working
C++ compiler and CMake. Everything shall be prepared to allow for either compiling
for the current platform or for cross-compiling to others.

For linux from linux do:

```
cd launcher
cmake -B build
cd build
make
```

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

