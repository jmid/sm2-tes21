(* The OCaml part *)

(* fac: example of a recursive function *)
let rec fac n =
  if n = 0
  then 1
  else n * fac (n - 1)

(* is_even and is_odd: two mutually recursive functions *)
let rec is_even n =
  if n = 0
  then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0
  then false
  else is_even (n - 1)

(* a pattern-matching example *)
let bool_to_string b = match b with
  | true -> "true"
  | false -> "false"

(* pattern matching with a wildcard _ pattern *)
let is_valid_bool s = match s with
  | "true" -> true
  | "false" -> true
  | _ -> false

(* fac - again - now written with pattern matching *)
let rec fac n = match n with
  | 0 -> 1
  | m -> m * fac (m - 1)

(* pattern matching a pair with a let *)
let distance_from_origo p =
  let (x,y) = p in
  let sqr_dist = x*x + y*y in
  sqrt (float_of_int sqr_dist)

(* patter matching a pair parameter in the header *)
let distance_from_origo' (x,y) =
  let sqr_dist = x*x + y*y in
  sqrt (float_of_int sqr_dist)

(* pattern matching over a list w/two cases: empty or non-empty list *)
let rec length l = match l with
  | [] -> 0
  | elem::elems -> 1 + length elems

(* labeled arguments example *)
let mymod ~num:n ~modulus:m = n mod m

(* labeled arguments short-hand notation (pattern is just a variable name) *)
let mymod' ~num ~modulus = num mod modulus

(* distance function adjusted to accept an optional argument *)
let distance ?(src = (0,0)) (tx,ty) =
  let (sx,sy) = src in
  let xdiff = tx - sx in
  let ydiff = ty - sy in
  let sqr_dist = xdiff*xdiff + ydiff*ydiff in
  sqrt (float_of_int sqr_dist)


(* QCheck part *)
  
open QCheck

let floor_test =
  Test.make ~name:"floor test" ~count:300 float (fun f -> floor f <= f)

let ceil_test =
  Test.make ~name:"ceil test" ~count:300 float (fun f -> f <= ceil f)

;;
QCheck_runner.run_tests ~verbose:true [floor_test; ceil_test]
;;
print_newline()


let is_even i = (i mod 2 = 0)
let is_odd i = (i mod 2 = 1)

(* example implication property *)
let succ_test =
  Test.make ~name:"succ test" (*~max_gen:200*)
    pos_int (fun i -> (is_even i) ==> (is_odd (succ i)))

(* writing implication as a combination of 'not' and '||' *)
let succ_test' =
  Test.make ~name:"succ test'" (*~max_gen:200*)
    pos_int (fun i -> (not (is_even i)) || (is_odd (succ i)))

(* an example test that throws an error *)
let div_test =
  Test.make ~name:"div test" small_signed_int (fun i -> (i <> 0) ==> (42 / i >= 0))

;;
QCheck_runner.run_tests ~verbose:true
    [succ_test;
     succ_test';
     div_test]
;;
print_newline()

(* an example agreement property: hand-written multiplication *)
let rec mymult n m = match n,m with
  | 0,_ -> 0
  | _,0 -> 0
  | _,_ ->
    let tmp = mymult (n lsr 1) m in
    if n land 1 = 0
    then (tmp lsl 1)
    else (tmp lsl 1) + m

let mymult_test =
  Test.make ~name:"mymult,* agreement"
            ~count:1000
    (pair int int) (fun (n,m) -> mymult n m = n * m)

;;
QCheck_runner.run_tests ~verbose:true [mymult_test]
;;
print_newline()

(* property: List.rev for singleton lists *)
let rev_sgl_test =
  Test.make ~name:"rev single"
    int (fun x -> List.rev [x] = [x])

(* property: two applications of List.rev is identity *)
let rev_twice_test =
  Test.make ~name:"rev twice"
    (list (int_range 0 100)) (fun xs -> List.rev (List.rev xs) = xs)

(* property: List.rev for two list parts *)
let rev_concat_test =
  Test.make ~name:"rev concat"
    (pair (list int) (list int))
    (fun (xs,ys) -> List.rev (xs @ ys) = (List.rev ys) @ (List.rev xs))

;;
QCheck_runner.run_tests ~verbose:true
    [rev_sgl_test;
     rev_concat_test;
     rev_twice_test]
