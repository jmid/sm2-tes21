open Intqc

let pt1 = make_test "dbl neg" Print.bool Gen.bool (fun b -> b = not (not b))
let pt2 = make_test "float eq" Print.float (Gen.float_bound 1.0) (fun f -> f = f)
let pt3 = make_test "list.rev and @" Print.(pair (list int) (list int)) Gen.(pair (list int) (list int))
    (fun (is,js) -> List.rev (is@js) = (List.rev js)@(List.rev is) )
let pt4 =
  let dep_gen = Gen.((int_bound 10) >>= fun i -> Gen.pair (Gen.return i) (Gen.listlen Gen.int i)) in
  make_test "dep gen" Print.(pair int (list int)) dep_gen (fun (i,xs) -> i = List.length xs)

let nt1 = make_test "neg test" Print.bool Gen.bool (fun b -> b = not b)
let nt2 = make_test "lessthan 12" Print.int Gen.int (fun i -> i < 12)
let nt3 = make_test "eq ints" Print.(pair int int) Gen.(pair int int) (fun (i,j) -> i = j)
let nt4 = make_test "gt ints" Print.(pair int int) Gen.(pair int int) (fun (i,j) -> i > j)
let nt5 = make_test "ints lt 128" Print.(pair int int) Gen.(pair int int) (fun (i,j) -> i+j<128)
let nt6 = make_test "lists are empty" Print.(list int) Gen.(list int) (fun is -> is = [])
let nt7 = make_test "lists are small" Print.(list int) Gen.(list int) (fun is -> List.length is < 5)
let nt8 = make_test "list.rev and @" Print.(pair (list int) (list int)) Gen.(pair (list int) (list int))
    (fun (is,js) -> List.rev (is@js) = (List.rev is)@(List.rev js) )
let nt9 = 
  let dep_gen = Gen.(int >>= fun i -> int_bound i >>= fun j -> return (i,j)) in
  make_test "pair dep gen" Print.(pair int int) dep_gen (fun (i,j) -> false)
let nt10 =
  let dep_gen = Gen.(int >>= fun i -> int >>= fun j -> return (i,j)) in
  make_test "less than" Print.(pair int int) dep_gen (fun (i,j) -> i < j)
let nt11 =
  let dep_gen = Gen.(int >>= fun i -> int >>= fun j -> return (i,j)) in
  make_test "greater than" Print.(pair int int) dep_gen (fun (i,j) -> i > j)
let nt12 =
  let dep_gen = Gen.((int_bound 10) >>= fun i -> pair (return i) (listlen int i)) in
  make_test "list dep gen" Print.(pair int (list int)) dep_gen (fun (i,xs) -> i = List.length xs && i<8)
let nt13 =
  let dep_gen = Gen.((int_bound 10) >>= fun i -> map (fun xs -> (i,xs)) (listlen int i)) in
  make_test "map dep gen" Print.(pair int (list int)) dep_gen (fun (i,xs) -> i = List.length xs && i<8)
;;
Printf.printf "\nPositive tests:\n";;
test_runner [pt1;pt2;pt3;pt4]
;;
Printf.printf "\n\nNegative tests:\n";;
test_runner [nt1;nt2;nt3;nt4;nt5;nt6;nt7;nt8;nt9;nt10;nt11;nt12;nt13]
;;
(*
let rs = Random.State.make_self_init () in
let Gen g = Gen.int_bound 10 in
Tree.print Print.int (g rs) |> print_endline
*)
;;
(*
let rs = Random.State.make(*_self_init ()*) [|0;1;2;3|] in
let Gen g = Gen.(pair (int_bound 5) (int_bound 5)) in
Tree.print_depth Print.(pair int int) (g rs) 10 |> print_endline
*)
(*
;;
let rs = Random.State.make(*_self_init ()*) [|0;1;2|] in
let Gen g = Gen.(pair bool (int_bound 5)) in
Tree.print_depth Print.(pair bool int) (g rs) 7 |> print_endline
;;
*)
(*
let rs = Random.State.make_self_init () in
let Gen g = Gen.bool in
Tree.print_depth Print.bool (g rs) 7 |> print_endline
*)
(*
print_endline "--------"
;;
let rs = Random.State.make(*_self_init ()*) [|0;1;2;3|] in
let Gen g = Gen.(int_bound 6) in
Tree.print_depth Print.int (g rs) 10 |> print_endline
*)
(*
let rs = Random.State.make(*_self_init ()*) [|0;1;2;3|] in
let Gen g = Gen.(list int) in
Tree.print_depth Print.(list int) (g rs) 10 |> print_endline
*)

(*
let rs = Random.State.make(*_self_init ()*) [|0;1;2|] in
let Gen g = Gen.(list int) in
Tree.print_depth Print.(list int) (g rs) 5 |> print_endline
*)

(*
let rs = Random.State.make(*_self_init ()*) [|0;1;2|] in
let g = Gen.(int_bound 10 >>= fun i -> Gen.map (fun j -> (i,j)) (int_bound 20)) in
(*let g = Gen.(pair (int_bound 10) (int_bound 20)) in *)
Tree.print_depth Print.(pair int int) (Gen.run_gen rs g) 7 |> print_endline
*)
(*
let rs = Random.State.make(*_self_init ()*) [|0;1;2|] in
let g = Gen.((int_bound 10) >>= fun i -> Gen.pair (Gen.return i) (Gen.listlen Gen.int i)) in
Tree.print_depth Print.(pair int (list int)) (Gen.run_gen rs g) 7 |> print_endline
*)

(* This generates 'true' and prints its shrink tree *)
let rs = Random.State.make [|0;1;2|] in
let g = Gen.bool in
Tree.print_depth Print.bool (Gen.run_gen rs g ) 7 |> print_endline
;;
let rs = Random.State.make [|0;1;2|] in
let g = Gen.int_bound 5 in
Tree.print_depth Print.int (Gen.run_gen rs g ) 7 |> print_endline

let rs = Random.State.make [|0;1;2|] in
let Gen g = Gen.(pair bool (int_bound 5)) in
Tree.print_depth Print.(pair bool int) (g rs) 7 |> print_endline


let bool_tree = (* generate true and its shrink tree *)
  let rs = Random.State.make [|0;1;2|] in
  Gen.run_gen rs Gen.bool;;
;;
Tree.print_depth Print.bool bool_tree 5 |> print_endline

let int_tree = (* generate 3 and its shrink tree *)
  let rs = Random.State.make [|5|] in
  Gen.run_gen rs (Gen.int_bound 5)
;;
Tree.print_depth Print.int int_tree 5 |> print_endline

let pair_tree = Gen.interleave (Tree.map (fun i1 i2 -> (i1,i2)) bool_tree) int_tree
;;
Tree.print_depth Print.(pair bool int) pair_tree 5 |> print_endline;;