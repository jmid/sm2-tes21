open QCheck
open Ctypes
open Foreign

let put   = foreign "put" (int @-> returning void)    (* void put(int n) *)
let get   = foreign "get" (void @-> returning int)    (* int get() *)
let reset = foreign "reset" (void @-> returning void) (* void reset() *)

module PGConf =
struct
  type cmd = Put of int | Get [@@deriving show { with_path = false }]
  type state = int
  type sut = unit

  let arb_cmd s =
    let int_gen = Gen.oneof [Gen.map Int32.to_int int32.gen; Gen.nat] in
    QCheck.make ~print:show_cmd
      (Gen.oneof [Gen.map (fun i -> Put i) int_gen; Gen.return Get])
      
  let init_state = 0
  let next_state c s = match c with
    | Put i -> i
    | Get   -> s

  let init_sut () = reset ()
  let cleanup () = ()
  let run_cmd c s () = match c with
    | Put i -> begin put i; true end
    | Get   -> (get () = s)

  let precond _ _ = true
end
module PGtest = QCSTM.Make(PGConf)
;;
QCheck_runner.run_tests ~verbose:true
  [PGtest.agree_test ~count:10_000 ~name:"put/get-model agreement"]
