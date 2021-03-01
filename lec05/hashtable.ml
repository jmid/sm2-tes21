open QCheck

(* This code requires the opam package qcstm:
      opam install qcstm

   To run it in utop/toplevel: 
     #require "qcheck";; 
     #require "qcstm";;
*)
module HConf =
struct
  type state = (string * int) list
  type sut   = (string, int) Hashtbl.t
  type cmd =
    | Add of string * int
    | Remove of string
    | Find of string
    | Mem of string [@@deriving show { with_path = false }]

  (*  gen_cmd : state -> cmd Gen.t  *)
  let gen_cmd s =
    let str_gen =
      if s = []
      then Gen.oneof [Gen.small_string;
                      Gen.string]
      else
        let keys = List.map fst s in
        Gen.oneof [Gen.oneofl keys;
                   Gen.small_string;
                   Gen.string] in
    Gen.oneof
      [ Gen.map2 (fun k v -> Add (k,v)) str_gen Gen.small_nat;
        Gen.map  (fun k   -> Remove k) str_gen;
        Gen.map  (fun k   -> Find k) str_gen;
        Gen.map  (fun k   -> Mem k) str_gen; ]

  let arb_cmd s = QCheck.make ~print:show_cmd (gen_cmd s)

  let init_state  = []
  let next_state c s = match c with
    | Add (k,v) -> (k,v)::s
    | Remove k  -> List.remove_assoc k s
    | Find _
    | Mem _     -> s

  let init_sut () = Hashtbl.create ~random:false 42
  let cleanup _   = ()
  let run_cmd c s h = match c with
    | Add (k,v) -> begin Hashtbl.add h k v; true end
    | Remove k  -> begin Hashtbl.remove h k; true end
    | Find k    ->
      List.assoc_opt k s = (try Some (Hashtbl.find h k)
                            with Not_found -> None)
    | Mem k     -> List.mem_assoc k s = Hashtbl.mem h k

  let precond _ _ = true
end
module HT = QCSTM.Make(HConf)
;;
QCheck_runner.run_tests ~verbose:true
  [HT.agree_test ~count:500 ~name:"Hashtbl-model agreement"]
