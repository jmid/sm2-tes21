open QCheck

(** Recursive and tail-recursive functions *)

(* a recursive sum function *)
let rec sum xs = match xs with
  | [] -> 0
  | x::xs -> x + sum xs

(* a tail-recursive sum function, passing an accumulator *)
let sum' xs =
  let rec sum_local xs acc = match xs with
    | [] -> acc
    | x::xs -> sum_local xs (x+acc)
  in sum_local xs 0

(* a recursive multiplication function *)
let rec mul xs = match xs with
  | [] -> 1
  | x::xs -> x * mul xs

(* a recursive concatenation function *)
let rec concat xs = match xs with
  | [] -> ""
  | x::xs -> x ^ concat xs

(* the same functions expressed with fold_left *)
let sum'' = List.fold_left (+) 0
let mul'' = List.fold_left ( * ) 0 (* spaces around '*' important: otherwise begins a comment! *)
let concat'' = List.fold_left (^) ""

let sums_agree_test =
  Test.make ~name:"accumulator agreement" ~count:10_000
    (list small_nat)
    (fun xs -> sum xs = sum' xs)

let sum_as_fold =
  Test.make ~name:"sum is fold"
    (list small_nat)
    (*(fun xs -> sum xs = List.fold_left (+) 0 xs)*)
    (fun xs -> sum xs = List.fold_left (fun acc x -> acc + x) 0 xs)

let concat_as_fold =
  Test.make ~name:"concat is fold"
    (list small_string)
    (*(fun xs -> concat xs = List.fold_left (^) "" xs)*)
    (fun xs -> concat xs = List.fold_left (fun acc s -> acc ^ s) "" xs)


(* examples of map and iter *)
let double x = x+x
let double_list xs = List.map double xs
let print_elems xs = List.iter (Printf.printf "%i ") xs


(** Generation of functions *)

(* Three fold tests *)
let fold_test1 =
  Test.make ~name:"fold over one element"
    (triple   (* string -> int -> string *)
       (fun2 Observable.string Observable.int small_string)
       small_string
       small_nat)
    (fun (f,acc,i) ->
       let f = Fn.apply f in
       List.fold_left f acc [i] = f acc i)

let fold_test2 =
  Test.make ~name:"folding over list halves"
    (quad  (* string -> int -> string *)
       (fun2 Observable.string Observable.int small_string)
       small_string
       (list small_nat)
       (list small_nat))
    (fun (f,acc,is,js) ->
       let f = Fn.apply f in
       List.fold_left f acc (is @ js)
       = List.fold_left f (List.fold_left f acc is) js)

let fold_test3 =
  Test.make ~name:"false fold, lists first"
    (quad  (* string -> int -> string *)
       (list small_nat)
       (list small_nat)
       (fun2 Observable.string Observable.int small_string)
       small_string)
    (fun (is,js,f,acc) ->
       let f = Fn.apply f in
       List.fold_left f acc (is @ js)
       = List.fold_left f (List.fold_left f acc is) is) (*Typo*)

let fold_test3' =
  Test.make ~name:"false fold, fun first"
    (quad  (* string -> int -> string *)
       (fun2 Observable.string Observable.int small_string)
       small_string
       (list small_nat)
       (list small_nat))
    (fun (f,acc,is,js) ->
       let f = Fn.apply f in
       List.fold_left f acc (is @ js)
       = List.fold_left f (List.fold_left f acc is) is) (*Typo*)
;;
QCheck_runner.run_tests ~verbose:true
  [sums_agree_test;
   sum_as_fold;
   concat_as_fold;
   fold_test1;
   fold_test2;
  ]
;;
QCheck_runner.set_seed 76543210;; (* comment this line out and try a few random seeds *)
QCheck_runner.run_tests ~verbose:true
  [fold_test3;
   fold_test3']
