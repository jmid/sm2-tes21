open QCheck
open Printf

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

  let init_sut () = ()
  let cleanup () = ()
  let run_cmd c s () = match c with
    | Put i -> begin printf " put(%i);\n" i; true end
    | Get   -> begin printf " assert(get () == %i);\n" s; true end

  let precond _ _ = true
end
module PGtest = QCSTM.Make(PGConf)

let t =
  Test.make ~name:"put/get printing" ~count:1
    (PGtest.arb_cmds 0) (* generator of commands *)
    (fun cs -> PGtest.interp_agree 0 () cs)
;;
QCheck_runner.run_tests ~verbose:true [t]
