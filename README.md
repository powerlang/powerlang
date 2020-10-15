# Powerlang

This is Powerlang, a research vehicle to explore about implementation of programming
laguages. While focused on Smalltalk, it aims to be a generic language creation
toolkit, something you can use to either evolve Smalltalk, or either build
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
in `bootstrap/specs/<your lang>`. Lets say you want to boostrap Bee Smalltalk:

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

You will need to build a launcher when you have an image segment file ready *(to-do:  document how)*.
For building the launcher, do this:

```
cd launcher
cmake . -B build
cd build && make
```

There you will find `bee-dmr` executable, just use it:

```
./bee-dmr kernel.ims
```



