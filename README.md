Introduction
============

ImageFlow is a node-based image editor for Mac OS X. It is currently
not meant to be used for real work, as many crucial features still
need to be implemented.

Building
========

To build ImageFlow, you need the following tools:

*  Apple's Xcode,
*  Objective Caml.

To install Objective Caml, you can either download and compile the
source from [the official homepage](http://caml.inria.fr/ocaml/) or
use a package manager like
[Homebrew](http://mxcl.github.com/homebrew/).

Once you have installed Objective Caml, you need to patch one of its
header files, to avoid a conflict between it and a system header. (This
is a [known issue](http://caml.inria.fr/mantis/view.php?id=4877).) For
that, open file `lib/ocaml/caml/config.h` from your Objective Caml
installation, and change the definition of `ARCH_UINT64_TYPE` so that
it reads:

    #define ARCH_UINT64_TYPE unsigned long long

instead of

    #define ARCH_UINT64_TYPE unsigned long

That being done, you still need to tell Xcode where Objective Caml was
installed, so that it can find the related header files during the
build process. Open Xcode's Preferences, select the "Source Trees" tab
and define a new one named `ocaml` and pointing to the directory in
which you installed Objective Caml. For example, if you used Homebrew
to install Objective Caml, the `ocaml` command is located in
`/usr/local/bin/ocaml`, and the source tree should be set to
`/usr/local`.

You are now ready to build ImageFlow. Open the Xcode project
(`ImageFlow.xcodeproj`) and look in the left panel for the list of
targets. You will see two of them:

1.  OCaml evaluator,
2.  ImageFlow.

Start by building the OCaml evaluator by right-clicking on its name
and selecting "Build OCaml evaluator". Then build and run the main
target, ImageFlow, using the same technique.
