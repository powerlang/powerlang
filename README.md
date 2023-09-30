# Powerlang

This is Powerlang, a framework to bootstrap Smalltalk images from specs (source
code in files). It aims to be a toolkit you can use to either evolve Smalltalk,
or otherwise build a new language implementation of choice.
In this repo we provide tools for bootstrapping  from files
in a pseudo-tonel format.

Powerlang contains a series of Smalltalk evaluators, which can be used to perform
the initialization stage of the baby Smalltalk, and also to run code after initialization
is finished. This is useful when debugging core components or the first steps your
system does (i.e. when it doesn't load).

Originally thought as a native-only project, now we
also support things like running on top of JavaScript engines. Tools for specific
platforms and operation modes can be found on other related repos. 

For example, for running on a fully self-hosted Live Metacircular Runtime (LMR)
you have `powerlang/lmr-cpp` which contains a launcher written in C++ and debug scripts.
In `powerlang/powerlang-js` you'll find the things needed to run a Smalltalk image
on top of JavaScript.

Bee Smalltalk served as a reference implementation using the framework.
We are implementing an evolution of the classic Smalltalk-80. Something
adapted to the new kinds of systems that are common these days: from
embedded to servers, with or without a gui, supporting local and remote development.
Visit [Powerlang docs](https://powerlang.readthedocs.io/en/latest/)
for documentation and [our blog](https://powerlang.github.io) for the latest news.

[![Actions Status](https://github.com/powerlang/powerlang/workflows/CI/badge.svg)](https://github.com/powerlang/powerlang/actions)
[![Documentation Status](https://readthedocs.org/projects/powerlang/badge/?version=latest)](https://powerlang.readthedocs.io/en/latest/?badge=latest)

# Building

**Note**: *following is tested by CI on Linux, for Windows, please refer to section
"Building launcher for Windows" at the end.*

After cloning the repo, run make to create a pharo bootstrap image. This image
will contain all the tools you need to generate your new image.

```
git clone git@github.com:powerlang/powerlang.git
```

Also you will need the sources of your language, that have to be placed
in `specs/<your lang>`. Lets say you want to bootstrap Bee Smalltalk:

```
git clone git@github.com:powerlang/bee-dmr.git specs/bee-dmr
echo "bee-dmr" >specs/current
```

Now, just do `make`:

```
make
```

This will genereate bootstrap.image, a Pharo image with the code needed
to bootstrap your own Smalltalk image. You can just open it and look for
Powerlang-* packages, and run tests. 
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

# How it works

The bootstrapper loads class and method definitions from files into a kind of spec objects.
The library used for that is called Ring2. With the class specs, the bootstrapper generates
a simulated image which contains all the objects needed to give life to the spec.

After the virtual image is generated, powerlang allows sending messages to the virtual
objects. 
To do that, powerlang includes an evaluator (actually, there are a few) that reads the
compiled methods and interprets them.
The idea is that you normally tell the virtual image to generate an image file for your
desired target platform.

For example, to generate a JavaScript kernel image (which is written in JSON format) you
would do:

```smalltalk
| bootstrapper module runtime filename |
bootstrapper := PowertalkRingImage fromSpec wordSize: 8; genesis; bootstrap; fillClasses; fillSymbols; generateLMR.
module := bootstrapper loadBootstrapModule.
runtime := bootstrapper result.
filename := runtime newString: 'kernel.json'.
runtime sendLocal: #writeJsonKernelTo: to: module with: {filename}"
```



