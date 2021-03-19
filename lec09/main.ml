open QCheck
open Typegen

(** Logic for writing to file and comparing **)

let write_prog src filename =
  let ostr = open_out filename in
  let () = output_string ostr src in
  close_out ostr

let typecheck_test =
  Test.make ~name:"output typechecks" ~count:1000
    (set_shrink Shrink.nil prog_arb) (*prog_arb*)
    (fun prog_opt -> match prog_opt with
       | None -> true
       | Some prog ->
         let file = "testdir/test.ml" in
         write_prog (exp_to_string prog) file;
	 0 = Sys.command ("ocamlc -w -5@20-26 " ^ file))

let run srcfile compname compcomm =
  let exefile = "testdir/" ^ compname in
  let outfile = exefile ^ ".out" in
  let exitcode = Sys.command (compcomm ^ " -o " ^ exefile ^ " " ^ srcfile) in
  if exitcode <> 0
  then
    failwith (compname ^ " compilation failed with error " ^ string_of_int exitcode)
  else (* Run the compiled program *)
    let runcode = Sys.command ("./" ^ exefile ^ " >" ^ outfile ^ " 2>&1") in
    (runcode, outfile)

let backend_eq_test =
  Test.make ~name:"backend equiv test" ~count:100
    prog_arb (fun prog_opt -> match prog_opt with
        | None -> true
        | Some prog ->
          let file = "testdir/test.ml" in
          let () = write_prog (exp_to_string prog) file in
          let ncode,nout = run file "native" "ocamlopt -O3 -w -5-26" in (*No warnings for partial appl.*)
          let bcode,bout = run file "byte" "ocamlc -w -5-26" in         (*        and unused variables *)
          let comp = Sys.command ("diff -q " ^ nout ^ " " ^ bout ^ " > /dev/null") in
          let res = ncode = bcode && comp = 0 in
          if res
          then res
          else (* for convenience: save a copy of last difference *)
            (Sys.rename file "testdir/prev.ml";
             Sys.rename nout "testdir/prev_native.out";
             Sys.rename bout "testdir/prev_byte.out";
             res))

;;
QCheck_runner.run_tests_main
  [ (*typecheck_test;*)
    backend_eq_test ]
