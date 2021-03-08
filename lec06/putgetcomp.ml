open QCheck
open Printf

module PGConf =
struct
  type cmd = Put of int | Get [@@deriving show { with_path = false }]
  type state = int
  type sut = out_channel (* was: unit *)

  let arb_cmd s =
    let int_gen = Gen.oneof [Gen.map Int32.to_int int32.gen; Gen.nat] in
    QCheck.make ~print:show_cmd
      (Gen.oneof [Gen.map (fun i -> Put i) int_gen; Gen.return Get])
      
  let init_state = 0
  let next_state c s = match c with
    | Put i -> i
    | Get   -> s

  let init_sut () =
    let ostr = open_out "tmp.c" in
    begin
      fprintf ostr "#include <assert.h>\n";
      fprintf ostr "int main() {\n";
      ostr
    end
  let cleanup ostr =
    begin
      fprintf ostr " return 0;\n";
      fprintf ostr "}\n";
      flush ostr;
      close_out ostr
    end
  let run_cmd c s ostr = match c with
    | Put i -> begin fprintf ostr " put(%i);\n" i; true end
    | Get   -> begin fprintf ostr " assert(get () == %i);\n" s; true end

  let precond _ _ = true
end
module PGtest = QCSTM.Make(PGConf)

let t =
  Test.make ~name:"compiled putget" ~count:500
    (PGtest.arb_cmds PGConf.init_state) (* generator of commands *)
    (fun cs ->
       let ostr = PGConf.init_sut () in
       ignore(PGtest.interp_agree PGConf.init_state ostr cs);
       PGConf.cleanup ostr;
       (* now compile and run program, checking exit codes *)
       0 = Sys.command ("gcc -Wall -Wextra -pedantic -Wno-implicit-function-declaration putgetlib.c tmp.c -o tmp")
         && 0 = Sys.command ("exec 2>tmp.stderr; ./tmp 1>tmp.stdout"))
;;
QCheck_runner.set_seed 256862321;;
QCheck_runner.run_tests ~verbose:true [t]
