let rec fac n = match n with
  | 0 -> 1
  | n -> n * fac (n - 1)
;;
Printf.printf "%i\n" (fac 0)


(*
  Now do:

  1. ocamlbuild -use-ocamlfind -package bisect_ppx fac.native
  2. BISECT_COVERAGE=YES ./fac.native
  3. bisect-ppx-report html

  Step 1 compiles the code with coverage instrumentation.
  Step 2 runs the code and collects coverage information.
         This is written to some file, e.g.,  bisect676950869.coverage
  Step 3 combines the code and the coverage information into an HTML report
         which is written to the _coverage/ directory.
         You can also pass bisect676950869.coverage as an argument
         to generate a report from that specific coverage file.

  If a coverage file already exists (from an earlier run)
  Step 2 will not overwrite it, but instead write to another one,
  e.g., 'bisect412840403.coverage'.

  This means you have to either
  - delete the old .coverage file when rerunning or
  - pass the filename in Step 3 above to match the latest output file.
*)
