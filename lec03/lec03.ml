open QCheck

(** OCaml part *)
type mybool =
  | Mytrue
  | Myfalse

let mybool_to_bool mb = match mb with
  | Mytrue -> true
  | Myfalse -> false

type card =
  | Clubs of int
  | Spades of int
  | Hearts of int
  | Diamonds of int

let card_to_string c = match c with
  | Clubs i    -> (string_of_int i) ^ " of clubs"
  | Spades i   -> (string_of_int i) ^ " of spades"
  | Hearts i   -> (string_of_int i) ^ " of hearts"
  | Diamonds i -> (string_of_int i) ^ " of diamonds"

let first_elem l = match l with
  | [] -> None
  | e::es -> Some e

(* a datatype of arithmetic expressions *)
type aexp =
  | X
  | Lit of int
  | Plus of aexp * aexp
  | Times of aexp * aexp

let mytree = Plus (Lit 1, Times (X, Lit 3))

(* our interpreter of arithmetic expressions *)
let rec interpret xval ae = match ae with
  | X -> xval
  | Lit i -> i
  | Plus (ae0, ae1) ->
    let v0 = interpret xval ae0 in
    let v1 = interpret xval ae1 in
    v0 + v1
  | Times (ae0, ae1) ->
    let v0 = interpret xval ae0 in
    let v1 = interpret xval ae1 in
    v0 * v1

(*  interpret mytree;;  *)

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

(*  exp_to_string mytree;;  *)

(* a datatype of abstract machine instructions *)
type inst =
  | Load
  | Push of int
  | Add
  | Mult

(* our compiler from arithmetic expressions to instructions *)
let rec compile ae = match ae with
  | X -> [Load]
  | Lit i -> [Push i]
  | Plus (ae0, ae1) ->
    let is0 = compile ae0 in
    let is1 = compile ae1 in
    is0 @ is1 @ [Add]
  | Times (ae0, ae1) ->
    let is0 = compile ae0 in
    let is1 = compile ae1 in
    is0 @ is1 @ [Mult]

(*  compile mytree;;  *)

let mycell = ref 0
;;
mycell := 42
;;
(*  !mycell;;  *)

type person = { name : string;
                age  : int  }

let someguy = { name = "Jan";
                age  = 77 }

let person_to_string p =
  p.name ^ ", " ^ (string_of_int p.age) ^ " years"

(*  person_to_string someguy;;  *)

exception Darn_list_is_empty

let first_elem' l = match l with
  | []    -> raise Darn_list_is_empty
  | e::es -> e      

(*  try first_elem' []
    with Darn_list_is_empty -> 0  *)
;;
begin
  print_string ("OMG OMG, this guy " ^ someguy.name);
  print_string ", he is like ";
  print_int someguy.age;
  print_endline " years old!!!"
end
;;

(** QuickCheck part *)

let leafgen = Gen.oneof
                [Gen.return X;
                 Gen.map (fun i -> Lit i) Gen.int]

(* an initial, direct generator without weights *)
let rec mygen n = match n with
  | 0 -> leafgen
  | n ->
    Gen.oneof
      [leafgen;
       Gen.map2 (fun l r -> Plus(l,r))  (mygen(n/2)) (mygen(n/2));
       Gen.map2 (fun l r -> Times(l,r)) (mygen(n/2)) (mygen(n/2)); ]

(* a direct generator with weights *)
let rec mygen' n = match n with
  | 0 -> leafgen
  | n ->
    Gen.frequency
      [(1,leafgen);
       (2,Gen.map2 (fun l r -> Plus(l,r))  (mygen'(n/2)) (mygen'(n/2)));
       (2,Gen.map2 (fun l r -> Times(l,r)) (mygen'(n/2)) (mygen'(n/2))); ]


(* a fixed-point generator without weights *)
let mygen'' =
  Gen.sized (Gen.fix (fun recgen n -> match n with
    | 0 -> leafgen
    | n ->
      Gen.oneof
	      [leafgen;
	       Gen.map2 (fun l r -> Plus(l,r)) (recgen(n/2)) (recgen(n/2));
	       Gen.map2 (fun l r -> Times(l,r)) (recgen(n/2)) (recgen(n/2)); ]))

(* a fixed-point generator with weights *)
let mygen''' =
  Gen.sized (Gen.fix (fun recgen n -> match n with
    | 0 -> leafgen
    | n ->
      Gen.frequency
	      [(1,leafgen);
	       (2,Gen.map2 (fun l r -> Plus(l,r)) (recgen(n/2)) (recgen(n/2)));
	       (2,Gen.map2 (fun l r -> Times(l,r)) (recgen(n/2)) (recgen(n/2))); ]))

let arb_tree = make ~print:exp_to_string (mygen 8)

let test_interpret =
  Test.make ~name:"test interpret"
    (pair small_signed_int arb_tree)
    (fun (xval,e) -> interpret xval (Plus(e,e))
                     = interpret xval (Times(Lit 2,e)))

(*
Gen.generate ~n:10 Gen.small_signed_int;;
Gen.generate1 mygen;;
Gen.generate1 mygen;;
 *)

(** Statistics *)

let rec msb n =
  if n = 0
  then 0
  else 1 + msb (n lsr 1)

let int_dist =
  let int_gen =
    set_stats [("msb",fun i -> msb i)] int in
  Test.make ~count:10000 ~name:"true" int_gen (fun _ -> true)

let list_len =
  let list_gen = set_stats [("list length",List.length)] (list int) in
  Test.make ~count:1000 list_gen (fun _ -> true)

let rec height ae = match ae with
  | X -> 0
  | Lit i -> 0
  | Plus (ae0, ae1) ->
    let h0 = height ae0 in
    let h1 = height ae1 in
    1 + (max h0 h1)
  | Times (ae0, ae1) ->
    let h0 = height ae0 in
    let h1 = height ae1 in
    1 + (max h0 h1)

let arb_tree = make ~print:exp_to_string mygen''

let tree_height =
  let mygen =
    make ~print:exp_to_string ~stats:[("tree height", height)] mygen'' in
  Test.make  ~count:1000 mygen (fun _ -> true)

let tree_height' =
  let mygen =
    make ~print:exp_to_string ~stats:[("tree height'", height)] mygen''' in
  Test.make ~count:1000 mygen (fun _ -> true)
             
(* Statistics with collect *)

let rec mymult n m = match n,m with
  | 0,_ -> 0
  | _,0 -> 0
  | _,_ ->
    let tmp = mymult (n lsr 1) m in
    if n land 1 = 0
    then (tmp lsl 1)
    else (tmp lsl 1) + m

let mymult_test =
  let sign n = if n=0 then "zero" else if n>0 then "pos" else "neg" in
  let pair_gen = set_collect
                   (fun (n,m) -> sign n ^ ", " ^ sign m)
                   (pair small_signed_int small_signed_int) in
  Test.make ~name:"mymult,* agreement"
    pair_gen (fun (n,m) -> mymult n m = n * m)

(* testing and exception throwing *)
let rec fac n = match n with
  | 0 -> 1
  | n -> n * fac (n - 1)

let test_fac_exc =
  Test.make ~name:"fac mod"
    (small_int_corners ())
    (fun n -> (fac n) mod n = 0)

let test_fac_exc' =
  Test.make ~name:"fac mod'"
    (small_int_corners ())
    (fun n -> try (fac n) mod n = 0
              with Division_by_zero -> (n=0)
                (*| Stack_overflow   -> false*) )


let test_negative =
  Test.make ~name:"test exc" ~count:1000
    (string_of_size Gen.small_nat)
    (fun s ->
       (s <> "true" && s <> "false")
       ==> try
             let _ = bool_of_string s in
             false
           with (Invalid_argument s) -> s = "bool_of_string")

;;
QCheck_runner.run_tests ~verbose:true
  [ test_interpret;
    int_dist;
    list_len;
    tree_height;
    tree_height';
    mymult_test;
    test_fac_exc;
    test_fac_exc';
    test_negative;
  ]
