# Developing Powerlang in Smalltalk/X

**Disclaimer**: Support for using Smalltalk/X as a development system for Powerlang
is an experimental work. Pharo is still the main development environment - changes
to bootstrap must work in Pharo but nobody's obliged to ensure they also work in Smalltalk/X.
This may or may not change in the (far) future.

Smalltalk/X support is mainly a courtesy to those who prefer Smalltalk/X environment over
Pharo (that is, @janvrany) and to allow experimentation with [libgdbs][4]

## Prerequisites

1.  Get [Smalltalk/X jv-branch][1]. Pre-build "toy" binaries for Linux
    can be found at [https://swing.fit.cvut.cz/download/smalltalkx/devel][2]:

        wget https://swing.fit.cvut.cz/download/smalltalkx/devel/YYYY-MM-DD_NNN/smalltalkx-jv-branch-8.0.99_buildNNN_x86_64-pc-linux-gnu.tar.bz2
        tar xf smalltalkx-jv-branch-8.0.99_buildNNN_x86_64-pc-linux-gnu.tar.bz2
        rm smalltalkx-jv-branch-8.0.99_buildNNN_x86_64-pc-linux-gnu.tar.bz2

    Alternatively, you may want to build Smalltalk/X from sources, see
    [build instructions][3]. This is actually *preferred way* to work with
    Smalltalk/X.

2.  Download an install Smalltalk/X port of RING2:

        mkdir -p ~/SmalltalkXProjects/stx/goodies
        hg clone https://swing.fit.cvut.cz/hg/stx-goodies-ring SmalltalkXProjects/stx/goodies/ring

## Loading

1.  Clone Powerlang:

        git clone https://github.com/powerlang/powerlang.git

2.  In Smalltalk/X workspace, execute:

		"Load PetitParser"
        Smalltalk loadPackage: 'stx:goodies/petitparser'.

        "Load RING "
        Smalltalk loadPackage:'stx:goodies/ring/core'.
        Smalltalk loadPackage:'stx:goodies/ring/core/tests'.
        Smalltalk loadPackage:'stx:goodies/ring/monticello'.
        Smalltalk loadPackage:'stx:goodies/ring/tooling'.

        "Load Powerlang"
        ParserFlags allowInheritedPools: true.
        Smalltalk packagePath add: '/where/you/cloned/powerlang/src'.
        Smalltalk loadPackage: 'Powerlang-Compatibility-SmalltalkX'.
        Smalltalk loadPackage: 'Powerlang-Core'.
        Smalltalk loadPackage: 'Powerlang-Tests'.

## Saving & Committing Changes

1.  Make sure you have moved all code to desired package.

2.  File out modified package(s):

       1. switch browser to package view - *View* ▷ *Package*
       2. then select modified package(s)
       3. and file them out in Tonel format - *Package* ▷ *File out* ▷ *Special Formats* ▷ *Tonel as...*.
       4. In file dialog, select directory where you want to file out packages (each package as a subdirectory). For example, if you cloned Powerlang to `/where/you/cloned/powerlang` then select `/where/you/cloned/powerlang/src`. In most cases, the correct directory should be pre-selected. but better check.

3.  Use your favorite GIT client to commit changes to repository.

[1]: https://swing.fit.cvut.cz/projects/stx-jv
[2]: https://swing.fit.cvut.cz/download/smalltalkx/devel
[3]: https://swing.fit.cvut.cz/projects/stx-jv/wiki/Documentation/BuildingStXWithRakefiles
[4]: https://swing.fit.cvut.cz/hg/jv-libgdbs/file/tip/README.md
