open QCheck
;;

(** First attempt: arbitrary strings *)

print_endline "\nArbitrary string generator output:";;
print_endline "----------------------------------";;
print_endline (Gen.generate1 (Gen.string ~gen:Gen.printable));;
print_endline (Gen.generate1 (Gen.string ~gen:Gen.printable));;
print_endline (Gen.generate1 (Gen.string ~gen:Gen.printable));;


(** Second attempt: a grammar-based generator *)

module GrammarBased =
struct
  type aexp =
    | X
    | Lit of int
    | Plus of aexp * aexp
    | Times of aexp * aexp

  let rec exp_to_string ae = match ae with
    | X -> "x"
    | Lit i -> string_of_int i
    | Plus (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      "(" ^ s0 ^ "+" ^ s1 ^ ")"
    | Times (ae0, ae1) ->
      let s0 = exp_to_string ae0 in
      let s1 = exp_to_string ae1 in
      "(" ^ s0 ^ "*" ^ s1 ^ ")"
  
  open Gen
  let leafgen = oneof [return X; map (fun i -> Lit i) small_signed_int]
  let mygen = sized (fix (fun rgen n -> match n with
      | 0 -> leafgen
      | n ->
        oneof
          [leafgen;
           map2 (fun l r -> Plus(l,r)) (rgen (n/2)) (rgen (n/2));
           map2 (fun l r -> Times(l,r)) (rgen (n/2)) (rgen (n/2))]
    ))

  ;;
  print_endline "\nGrammar-based generator output:";;
  print_endline "-------------------------------";;
  print_endline (exp_to_string (Gen.generate1 mygen));;
  print_endline (exp_to_string (Gen.generate1 mygen));;
  print_endline (exp_to_string (Gen.generate1 mygen));;
end


(** A revised attempt with several variables *)

module MoreVars =
struct
  type aexp =
    | Var of string
    | Lit of int
    | Plus of aexp * aexp
    | Times of aexp * aexp

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
  
  open Gen
  let vargen = string_size ~gen:(char_range 'a' 'z') (int_range 1 10)
  let leafgen =
    oneof [map (fun v -> Var v) vargen;
           map (fun i -> Lit i) small_signed_int]
  let mygen = sized (fix (fun rgen n -> match n with
      | 0 -> leafgen
      | n ->
        oneof
          [leafgen;
           map2 (fun l r -> Plus(l,r)) (rgen (n/2)) (rgen (n/2));
           map2 (fun l r -> Times(l,r)) (rgen (n/2)) (rgen (n/2))]
    ))
  ;;
  print_endline "\nGrammar-based generator output w/several variables:";;
  print_endline "---------------------------------------------------";;
  print_endline (exp_to_string (Gen.generate1 mygen));;
  print_endline (exp_to_string (Gen.generate1 mygen));;
  print_endline (exp_to_string (Gen.generate1 mygen));;
end

(** A revised attempt with a variable environment *)

module VarEnv =
struct
  type aexp =
    | Var of string
    | Lit of int
    | Plus of aexp * aexp
    | Times of aexp * aexp

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
  
  open Gen
  let vargen = string_size ~gen:(char_range 'a' 'z') (int_range 1 10)

  let leafgen env = match env with
    | [] -> map (fun i -> Lit i) small_signed_int
    | _  -> oneof [map (fun v -> Var v) (oneofl env);
                   map (fun i -> Lit i) small_signed_int]

  let mygen env = sized (fix (fun rgen n -> match n with
      | 0 -> leafgen env
      | n ->
        oneof
          [leafgen env;
           map2 (fun l r -> Plus(l,r)) (rgen (n/2)) (rgen (n/2));
           map2 (fun l r -> Times(l,r)) (rgen (n/2)) (rgen (n/2))]
    ))

  let proggen = Gen.small_list vargen >>= fun env -> mygen env
  ;;
  print_endline "\nGrammar-based generator output w/environment:";;
  print_endline "---------------------------------------------";;
  print_endline (exp_to_string (Gen.generate1 proggen));;
  print_endline (exp_to_string (Gen.generate1 proggen));;
  print_endline (exp_to_string (Gen.generate1 proggen));;
end

