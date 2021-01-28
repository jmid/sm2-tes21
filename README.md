SM2-TES: Functional Programming and Property-Based Testing
==========================================================

This repository contains course material for the course 'SM2-TES:
Functional Programming and Property-Based Testing' held at the
University of Southern Denmark, Spring 2021.


Useful resources
----------------

[Installation instructions](INSTALL.md)

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
