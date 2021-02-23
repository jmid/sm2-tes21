open QCheck

(* We can also locally open a module *)
let somepairs =
  let open Gen in
  generate ~n:10 (pair bool small_string)

(* An even shorter version *)
let somepairs' =
  Gen.(generate ~n:10 (pair bool small_string))

(* Compare with the same code, with explicit Gen: *)
let somepairs'' =
  Gen.generate ~n:10 (Gen.pair Gen.bool Gen.small_string)


(* An example of functor application: creating sets of integers *)
module Intset =
  Set.Make (struct
             type t = int
             let compare n1 n2 =
               if n1 = n2 then 0 else
                 if n1 > n2 then 1 else -1
           end)

(* Utilizing the Stdlib's Int module to achieve the same *)
module Intset = Set.Make (Int)

(* Now we can work with them: *)
let someset =
  Intset.elements (Intset.union (Intset.of_list [0;2;4;5]) (Intset.singleton 42))

(* Another example of functors: creating maps/dictionaries with string keys *)
module Mymap =
  Map.Make (struct
             type t = string
             let compare = String.compare
           end)

(* or similarly:
module Mymap = Map.Make (String) *)

(* Example using the map: *)
let somemap =
  Mymap.bindings (Mymap.add "a" 1 (Mymap.add "b" 2 (Mymap.singleton "c" 3)))


(* an example signature delimiting a module's visible content *)
module X: sig
  (* contents of file x.mli *)
  type t (*= string * (int -> string)*)
  val b : t
end
= struct
  (* contents of file x.ml *)
  type t = string * (int -> string)
  let a = ("foo",string_of_int)
  let b = ("bar",fun _ -> "hello")
end


 (** Shrinking *)

(* the false list example with/without shrinking *)
let rev_thrice_test =
  Test.make ~name:"rev thrice"
    (set_shrink Shrink.nil (list int))
    (*(list int)*)
    (fun xs -> List.rev (List.rev (List.rev xs)) = xs)

(* the false aexp example with/without shrinking *)
type aexp =
  | X
  | Lit of int
  | Plus of aexp * aexp
  | Times of aexp * aexp

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

let leafgen = Gen.oneof
                [Gen.return X;
                 Gen.map (fun i -> Lit i) Gen.int]

let mygen =
  Gen.sized (Gen.fix (fun recgen n -> match n with
    | 0 -> leafgen
    | n ->
      Gen.oneof
	      [leafgen;
	       Gen.map2 (fun l r -> Plus(l,r)) (recgen(n/2)) (recgen(n/2));
	       Gen.map2 (fun l r -> Times(l,r)) (recgen(n/2)) (recgen(n/2)); ]))

let arb_tree = make ~print:exp_to_string mygen

let wrong_test =
  Test.make ~name:"aexp is zero when x is"
    arb_tree
    (fun e -> interpret 0 e = 0)

(* a bit on iterators *)

let i = Iter.of_list [0;1;2;3;4;5]
(* 
 Iter.find (fun i -> true) i;;
 Iter.find (fun i -> i>=3) i;;
 Iter.find (fun i -> i>=10) i;;
 *)


(* back to shrinking *)

(* tree shrinker written with prefix Iter.append *)
let rec tshrink e = match e with
  | X -> Iter.empty
  | Lit i -> Iter.map (fun i' -> Lit i') (Shrink.int i)
  | Plus (ae0, ae1) ->
     Iter.append (Iter.of_list [ae0; ae1])
                 (Iter.append
                    (Iter.map (fun ae0' -> Plus (ae0',ae1)) (tshrink ae0))
                    (Iter.map (fun ae1' -> Plus (ae0,ae1')) (tshrink ae1)))
  | Times (ae0, ae1) ->
     Iter.append (Iter.of_list [ae0; ae1])
                 (Iter.append
                    (Iter.map (fun ae0' -> Times (ae0',ae1)) (tshrink ae0))
                    (Iter.map (fun ae1' -> Times (ae0,ae1')) (tshrink ae1)))

(* tree shrinker written with infix Iter.append *)
let (<+>) = Iter.(<+>)
let rec tshrink e = match e with
  | X -> Iter.empty
  | Lit i -> Iter.map (fun i -> Lit i) (Shrink.int i)
  | Plus (ae0, ae1) ->
     (Iter.of_list [ae0; ae1])
     <+> (Iter.map (fun ae0' -> Plus (ae0',ae1)) (tshrink ae0))
     <+> (Iter.map (fun ae1' -> Plus (ae0,ae1')) (tshrink ae1))
  | Times (ae0, ae1) ->
     (Iter.of_list [ae0; ae1])
     <+> (Iter.map (fun ae0' -> Times (ae0',ae1)) (tshrink ae0))
     <+> (Iter.map (fun ae1' -> Times (ae0,ae1')) (tshrink ae1))

let wrong_test' =
  Test.make ~name:"aexp is zero when x is'"
    (set_shrink tshrink arb_tree)
    (fun e -> interpret 0 e = 0)
;;
QCheck_runner.run_tests ~verbose:true
 [ rev_thrice_test;
   wrong_test;
   wrong_test';
 ]
