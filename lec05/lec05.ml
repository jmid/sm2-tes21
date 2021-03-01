open QCheck

(* This code requires the opam package ppx_deriving:
     opam install ppx_deriving

   To run it in utop/toplevel: 
     #require "ppx_deriving.show";; *)

(** A first version, without cmd shrinking *)

module HT1 =
struct
  type cmd =
    | Add of string * int
    | Remove of string
    | Find of string
    | Mem of string [@@deriving show { with_path = false }]

  (*  gen_cmd : cmd Gen.t  *)
  let gen_cmd =
    let str_gen = Gen.oneof [Gen.small_string;
                             Gen.string] in
    Gen.oneof
      [ Gen.map2 (fun k v -> Add (k,v)) str_gen Gen.small_nat;
        Gen.map  (fun k   -> Remove k) str_gen;
        Gen.map  (fun k   -> Find k) str_gen;
        Gen.map  (fun k   -> Mem k) str_gen; ]

  (*  arb_cmd : cmd QCheck.arbitrary *)
  let arb_cmd = make ~print:show_cmd gen_cmd

  (*  arb_cmds : cmd list QCheck.arbitrary *)
  let arb_cmds = list arb_cmd

  type state = (string * int) list

  (* next_state : cmd -> state -> state *)
  let next_state c s = match c with
    | Add (k,v) -> (k,v)::s
    | Remove k  -> List.remove_assoc k s
    | Find _
    | Mem _     -> s

  (*  run_cmd : cmd -> state -> (string, int) Hashtbl.t -> bool *)
  let run_cmd c s h = match c with
    | Add (k,v) ->
      (* begin Hashtbl.add h k v; true end *)
      (* begin Hashtbl.add h k (v+1); true end *)
      begin
        if String.length k <= 2 then Hashtbl.add h k v else Hashtbl.add h k (v+1); 
        true
      end
    | Remove k  -> begin Hashtbl.remove h k; true end
    | Find k    ->
      List.assoc_opt k s = (try Some (Hashtbl.find h k)
                            with Not_found -> None)
    | Mem k     -> List.mem_assoc k s = Hashtbl.mem h k

  (*  interp_agree : state -> (string, int) Hashtbl.t -> cmd list -> bool *)
  let rec interp_agree s h cs = match cs with
    | [] -> true
    | c::cs ->
      let b = run_cmd c s h in
      let s' = next_state c s in
      b && interp_agree s' h cs

  (*  agree_test : QCheck.Test.t  *)
  let agree_test =
    Test.make ~name:"Hashtbl-model agreement w/o state-dependence" ~count:500
      arb_cmds
      (fun cs -> interp_agree [] (Hashtbl.create ~random:false 42) cs)
  ;;
  QCheck_runner.run_tests ~verbose:true [agree_test]
end


(** A second version, with state-dependent cmd generation *)

module HT2 =
struct
  include HT1

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

  (*  gen_cmds : state -> int -> cmd list QCheck.Gen.t *)
  let rec gen_cmds s fuel =
    let open Gen in
    if fuel = 0
    then Gen.return []
    else
      gen_cmd s >>= fun c ->
        (gen_cmds (next_state c s) (fuel-1)) >>= fun cs ->
           return (c::cs)

  (*  arb_cmds : cmd list QCheck.arbitrary *)
  let arb_cmds =
    make ~print:(Print.list show_cmd) ~shrink:Shrink.list
      (Gen.sized (gen_cmds []))

  (*  agree_test : QCheck.Test.t  *)
  let agree_test =
    Test.make ~name:"Hashtbl-model agreement w/ state-dependence" ~count:500
      arb_cmds
      (fun cs -> interp_agree [] (Hashtbl.create ~random:false 42) cs)
  ;;
  QCheck_runner.run_tests ~verbose:true [agree_test]
end
