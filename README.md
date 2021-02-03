SM2-TES: Functional Programming and Property-Based Testing
==========================================================

This repository contains course material for the course 'SM2-TES:
Functional Programming and Property-Based Testing' held at the
University of Southern Denmark, Spring 2021.


Useful resources
----------------

[Installation instructions](INSTALL.md)

[A minimal example of QCheck, ocamlfind, and ocamlbuild](https://github.com/jmid/qcheck-example)

[OCaml standard library](http://caml.inria.fr/pub/docs/manual-ocaml/libref/)

[QCheck documentation](http://c-cube.github.io/qcheck/0.16/qcheck/)


Top-level directives:
=====================

Both `utop` and the `ocaml` read-eval-print loop accepts a number of "directives"
documented in the manual, [chapter 10.2](https://caml.inria.fr/pub/docs/manual-ocaml/toplevel.html#sec298).

These are strictly speaking not part of the OCaml language - just helpful instructions
to the interactive interpreters. As such, I wouldn't put them in source code.

 - `#use "filename.ml";;`  loads OCaml source code into the read-eval-print loop. It stops on the first error.

 - `#show identifier;;`   prints the type of a variable or module.

 - `#use "topfind";;`    loads a helper program to easily load packages. `topfind` is loaded automatically by `utop`.

    After loading `topfind` additional directives are available:

    * `#require "packagename";;`   for loading a package, e.g., `qcheck`.

    * `#list;;`           prints a list of installed packages

 - ...


Cool uses of OCaml:
===================

Here's some example uses of OCaml:

 - [MirageOS](https://mirage.io/) is a library for creating unikernel operating systems in OCaml

 - [Docker for Windows and Mac uses OCaml and parts of MirageOS](https://www.docker.com/blog/docker-for-mac-windows-beta/)

 - [NetHSM from Nitrokey is an open source HSM based on OCaml and MirageOS](https://www.nitrokey.com/products/nethsm)

 - [Facebook](https://github.com/facebook/) uses OCaml in a number of open source projects:
   * [Infer](https://github.com/facebook/infer): a static analysis for Java, C, C++, ...
   * [Flow](https://github.com/facebook/flow): a type system for JavaScript
   * [Pyre](https://github.com/facebook/pyre-check): a type analysis for Python
   * ...

 - Microsoft uses OCaml:
   * [Infer#](https://github.com/microsoft/infersharp) is a C# analysis frontend for Facebook's Infer
   * [The static device driver verifier](https://en.wikipedia.org/wiki/SLAM_project) was written in OCaml

 - [Astrée from AbsInt](https://www.absint.com/astree/) is a [static analysis tool written in OCaml](https://www.astree.ens.fr/). It is used to analyze and prevent errors, e.g., in Airbus software

 - ...

[The Wikipedia page for OCaml](https://en.wikipedia.org/wiki/OCaml#Software_written_in_OCaml) also lists users of OCaml.

ocaml.org maintains a list of [companies that use OCaml](https://ocaml.org/learn/companies.html).
