open QCheck

module StmtLang =
struct
  type aexp =
    | Var of string
    | Lit of int
    | Plus of aexp * aexp
    | Times of aexp * aexp

  type relexp =
    | False
    | True
    | Lt of aexp * aexp
    | Le of aexp * aexp
    | Equal of aexp * aexp

  type stmt =
    | Assign of string * aexp
    | Block of stmt list
    | If of relexp * stmt
    | While of relexp * stmt
  
  let rec exp_to_string ae = match ae with
    | Var x -> x
    | Lit i -> string_of_int i
    | Plus (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      "(" ^ s0 ^ "+" ^ s1 ^ ")"
    | Times (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      "(" ^ s0 ^ "*" ^ s1 ^ ")"

  let rec relexp_to_string ae = match ae with
    | False -> "0"
    | True  -> "1"
    | Lt (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      s0 ^ " < " ^ s1
    | Le (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      s0 ^ " <= " ^ s1
    | Equal (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      s0 ^ " == " ^ s1

  let rec stmt_to_string s = match s with
    | Assign (x, ae) ->
      x ^ " = " ^ (exp_to_string ae) ^ "\n"
    | Block ss ->
      "{ " ^ String.concat "\n" (List.map stmt_to_string ss) ^ "}\n"
    | If (re, s) ->
      "if (" ^ relexp_to_string re ^ ") " ^ stmt_to_string s ^ "\n"
    | While (re, s) ->
      "while (" ^ relexp_to_string re ^ ")\n   " ^ stmt_to_string s

  open Gen
  let vargen = string_size ~gen:(char_range 'a' 'z') (int_range 1 10)

  let leafgen env = match env with
    | [] -> map (fun i -> Lit i) small_signed_int
    | _  -> oneof [map (fun v -> Var v) (oneofl env);
                   map (fun i -> Lit i) small_signed_int]

  let aexp env = fix (fun rgen n -> match n with
      | 0 -> leafgen env
      | _ ->
        oneof
          [leafgen env;
           map2 (fun l r -> Plus(l,r))  (rgen (n/2)) (rgen (n/2));
           map2 (fun l r -> Times(l,r)) (rgen (n/2)) (rgen (n/2))])

  let relexpgen env n = match n with
      | 0 -> oneofl [False; True]
      | _ ->
        oneof
          [oneofl [False; True];
           map2 (fun l r -> Lt(l,r))    (aexp env (n/2)) (aexp env (n/2));
           map2 (fun l r -> Le(l,r))    (aexp env (n/2)) (aexp env (n/2));
           map2 (fun l r -> Equal(l,r)) (aexp env (n/2)) (aexp env (n/2))]

  let assign_gen env n = match env with
    | [] -> map2 (fun x ae -> Assign (x,ae)) vargen (aexp env n)    (*new var*)
    | _  ->
      oneof [
        map2 (fun x ae -> Assign (x,ae)) (oneofl env) (aexp env n); (*known var*)
        map2 (fun x ae -> Assign (x,ae)) vargen (aexp env n) ]      (*new var*)
  
  let rec stmtgen env = fix (fun rgen n -> match n with
      | 0 -> assign_gen env n
      | _ ->
        oneof
          [assign_gen env n;
           map  (fun ss   -> Block ss)     (stmtlistgen env (n-1));
           map2 (fun re s -> If (re,s))    (relexpgen env (n/2)) (rgen (n/2));
           map2 (fun re s -> While (re,s)) (relexpgen env (n/2)) (rgen (n/2));
          ])
  and stmtlistgen env n = match n with
    | 0 -> return []
    | _ ->
      stmtgen env (n/2) >>= fun s ->
          let env' = (match s with
            | Assign (x,_) -> if List.mem x env then env else x::env
            | _ -> env) in
          stmtlistgen env' (n/2) >>= fun ss -> return (s::ss)

  let rec stmt_shrink s = match s with
    | Block ss ->
      Iter.map (fun ss' -> Block ss') (Shrink.list ~shrink:stmt_shrink ss)
    | If (e,s) ->
      Iter.(
        return s
        <+>
        map (fun s' -> If (e,s')) (stmt_shrink s))
    | While (e,s) ->
      Iter.(
        return s
        <+>
        map (fun s' -> While (e,s'))  (stmt_shrink s))
    | _ -> Iter.empty

  ;;
  print_endline "\nGrammar-based generator of statements w/environment:";;
  print_endline "----------------------------------------------------";;
  print_endline (stmt_to_string (Gen.generate1 (sized (stmtgen []))));;
  print_endline "----------------------------------------------------";;
  print_endline (stmt_to_string (Gen.generate1 (sized (stmtgen []))));;
  print_endline "----------------------------------------------------";;
  print_endline (stmt_to_string (Gen.generate1 (sized (stmtgen []))));;
end

let arb_stmt =
  make ~print:StmtLang.stmt_to_string ~shrink:StmtLang.stmt_shrink
    (Gen.sized (StmtLang.stmtgen []))

let test =
  Test.make ~count:100 ~name:"bc test"
    arb_stmt
    (fun stmt ->
       let outch = open_out "tmp.bc" in
       Printf.fprintf outch "%s" (StmtLang.stmt_to_string stmt);
       close_out outch;
       let retcode = Sys.command "timeout 2 bc -q < tmp.bc > output.txt 2>&1 " in
       (retcode = 0 || retcode = 124) 
        && 0 <> Sys.command "grep -q error output.txt")

;;
QCheck_runner.run_tests ~verbose:true [test]
