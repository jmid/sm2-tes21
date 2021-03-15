Lecture 8: Case study: computational geometry, coverage, program generation
===========================================================================

1. a. Install bisect_ppx using opam with

       opam install bisect_ppx

   b. Download and rerun the factorial example in [fac.ml](fac.ml)

      You need to perform the three required steps:

        1. ocamlbuild -use-ocamlfind -package bisect_ppx fac.native
        2. BISECT_COVERAGE=YES ./fac.native
        3. bisect-ppx-report html

      Alternatively, just run `make fac` which should perform all three.

      Check that you can recreate a coverage report.

   c. Now change the `fac` call in [fac.ml](fac.ml) to `fac 5`.
      Remove the old instrumentation data file, e.g., `bisect068840590.coverage`
      and rerun the three steps.

      Open the coverage report for [fac.ml](fac.ml) in [_coverage/index.html](_coverage/index.html) and "mouse over" the coverage counts.

      Can you explain the new coverage counts?


2. Extend `aexp` in the `VarEnv`-module of [lec08.ml](lec08.ml) with minus and division.
   You will need to extend the type `aexp`, the printer `exp_to_string`, and the generator `mygen`.


3. The shrinker in [stmtlang.ml](stmtlang.ml) only shrinks statements.

   Extend `stmt_shrink` with shrinkers of arithmetic expressions and Boolean
   (relational) expressions.


4. Finally I encourage you to
   - discuss and talk to me about/investigate potential project ideas
   - get started on your project (assuming green light from me)

   I'll be happy to give input on properties, generators, etc.
