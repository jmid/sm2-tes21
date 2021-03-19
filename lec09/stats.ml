open QCheck
open Typegen

(** Statistic on generator failure *)

let failure_test =
  Test.make ~name:"failure stats" ~count:100000
    (set_collect (fun opt -> if opt = None then "fail" else "succ") prog_arb)
    (fun _ -> true)


(** Statistic on binary applications *)

let rec contains_binop_call e = match e with
  | Lit _
  | Var _ -> false
  | Lam (x,e) -> contains_binop_call e
  | App (e0,e1) -> (match e0 with
      | App (Var x, _) -> List.mem x ["(+)"; "(-)"; "( * )"; "(/)"; "(mod)"; "(^)"]
      | _              -> false)
                   || contains_binop_call e0 || contains_binop_call e1
  | Let (x,e0,e1) -> contains_binop_call e0 || contains_binop_call e1
  | Indir (f,es) ->
    List.mem f ["(+)"; "(-)"; "( * )"; "(/)"; "(mod)"; "(^)"]
     || List.exists contains_binop_call es

let binop_test =
  Test.make ~name:"binop stats" ~count:10000
    (set_collect
       (fun opt -> match opt with
         | None   -> "no binop"
         | Some e ->
           if contains_binop_call e then "some binop" else "no binop")
        prog_arb)
    (fun _ -> true)

;;
QCheck_runner.run_tests_main
  [ failure_test;
    binop_test ]
