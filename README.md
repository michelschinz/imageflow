Introduction
============

ImageFlow is a node-based image editor for Mac OS X.

Building
========

To build ImageFlow, you need the following tools:

*  Apple's Xcode,
*  Objective Caml.

To install Objective Caml, you can either download and compile the
source from [the official homepage](http://caml.inria.fr/ocaml/), or
use a package manager like
[Homebrew](http://mxcl.github.com/homebrew/).

Once you have installed the various dependencies, the easiest way to
build ImageFlow is to do it from within Xcode. First open the Xcode
project (ImageFlow.xcodeproj) and then look in the left panel for the
list of targets. You will see two of them:

1.  OCaml evaluator,
2.  ImageFlow.

First build the OCaml evaluator by right-clicking on its name and
selecting Build OCaml evaluator. Then build and run the main target,
ImageFlow, using the same technique.
