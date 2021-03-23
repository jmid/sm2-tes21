(** {1 Intqc: A small property-based testing library with integrated shrinking } *)

(**  Print module of to_string combinators *)
module Print
= struct
  type 'a t = 'a -> string
  let bool : bool t = string_of_bool
  let char : char t = String.make 1 
  let int : int t = string_of_int
  let float : float t = string_of_float
  let pair (pr1 : 'a t) (pr2 : 'b t) : ('a * 'b) t = fun (i,j) -> Printf.sprintf "(%s,%s)" (pr1 i) (pr2 j)
  let list (elempr : 'a t) : 'a list t =
    fun is -> (fst (List.fold_left (fun (acc,sep) i -> (acc ^ sep ^ elempr i,"; ")) ("[","") is)) ^ "]"
end

(**  Module for representing shrinking trees (Rose trees) *)
module Tree
= struct
  type 'a t  = Node of 'a * 'a t Seq.t  (** Rose tree type *)
  
  let return a = Node (a, Seq.empty) (** A tree without children *)
  let rec map f (Node (a, rst)) = Node (f a, Seq.map (map f) rst)

  let rec join (Node (Node (x, xs), xss)) = Node (x, Seq.append (Seq.map join xss) xs)
    
  (*  bind : 'a Tree.t -> ('a -> 'b Tree.t) -> 'b Tree.t *)
  let rec bind (Node (a,arst)) k =
    let Node (b,rst') = k a in
    let rst'' = Seq.map (fun m -> bind m k) arst in
    Node (b, Seq.append rst'' rst')
  
  (*  print_depth : 'a Print.t -> 'a Tree.t -> int -> string *)
  let print_depth (elpr : 'a Print.t) t depth =
    (*  walk_tree : string -> 'a t -> string *)
    let rec walk_tree prefix (Node (t,rst)) depth =
      if depth = 0
      then prefix ^ " ..."
      else
        let s = Printf.sprintf "%s %s" prefix (elpr t) in
        let ss = walk_seq (prefix ^ " └─") rst (depth-1) in
        String.concat "\n" (s::ss)
    (*  walk_seq : string -> 'a seq -> string list *)
    and walk_seq prefix ss depth = match ss () with
      | Seq.Nil -> []
      | Seq.Cons (a,rst) ->
        if depth = 0
        then [prefix ^ " ..."]
        else
          let s = walk_tree prefix a depth in
          let ss = walk_seq prefix rst (depth-1) in
          s::ss
    in walk_tree "" t depth
end

(**  Module of generator combinators *)
module Gen
= struct
  type 'a t = Gen of (Random.State.t -> 'a Tree.t)

  let run_gen rs (Gen g) = g rs

  (*  return 'a -> 'a Gen.t  *)
  let return a = Gen (fun _ -> Tree.return a)
  let const = return
  
  let random_split rs = (* crude splitter of random state *)
    let rs' = Random.State.copy rs in
    let _ = Random.State.bool rs' in
    (rs,rs')
  
  (*  bind : 'a Gen.t -> ('a -> 'b Gen.t) -> 'b Gen.t  *)
  let bind (Gen m) k =
    Gen (fun rs ->
           let rs,rs' = random_split rs in
           Tree.bind (m rs) (fun a -> run_gen rs' (k a)))
    
  let (>>=) = bind
  
  (*  bool : bool Gen.t  *)
  let bool =
    Gen (fun rs ->
          let b = Random.State.bool rs in
          Node (b, if b then Seq.return (Tree.return false) else Seq.empty))

  (*  float_bound : float -> float Gen.t  *)
  let float_bound bound =
    Gen (fun rs ->
          let f = Random.State.float rs bound in
          Tree.return f) (* FIXME: no shrinking *)

  let shrink_seq i = match i with
    | 0 -> Seq.empty
    | _ ->
      fun () ->
        let i' = i / 2 in
        if i<3 then Seq.return i' ()
        else 
          let i'' = if i > 0 then pred i else succ i in
          Seq.cons i' (Seq.cons i'' Seq.empty) ()

  let rec shrink_int i = Seq.map (fun i' -> Tree.Node (i',shrink_int i')) (shrink_seq i)

  (*  int : int Gen.t  *)
  let int =
    Gen (fun rs ->
          let i = Random.State.int rs (max_int lsr 32) in (*FIXME: 32-bit, no chance of max_int*)
          Node (i, shrink_int i))

  (*  int_bound : int -> int Gen.t  *)
  let int_bound b = (* inclusive bound *)
    if b >= max_int lsr 32 (*FIXME: 32-bit*)
    then failwith ("int_bound: too big argument " ^ string_of_int b)
    else
      Gen (fun rs ->
            let i = Random.State.int rs (b+1) in 
            Node (i, shrink_int i))

  (*  char : char Gen.t  *)
  let char =
      Gen (fun rs ->
            let i = Random.State.int rs 256 in
            Tree.return (char_of_int i)) (* FIXME: no shrinking *)

  (*  interleave : ('a -> 'b) Tree.t -> 'a Tree.t -> 'b Tree.t  *)
  let rec interleave (Tree.Node (i1, shk1) as n1) (Tree.Node (i2, shk2) as n2) =
    Tree.Node (i1 i2,
               Seq.append
                 (Seq.map (fun l' -> interleave l' n2) shk1)
                 (Seq.map (fun r' -> interleave n1 r') shk2))

  (*  app : ('a -> 'b) Gen.t -> 'a Gen.t -> 'b Gen.t  *)
  let app (Gen f) (Gen x) =
    Gen (fun rs ->
           let rs,rs' = random_split rs in
           let ftree = f rs in
           let xtree = x rs' in (* FIXME: split randomness source w/splitmix *)
           interleave ftree xtree)

  (*  map : ('a -> 'b) -> 'a Gen.t -> 'b Gen.t  *)
  let map f (Gen g) = Gen (fun rs -> Tree.map f (g rs))

  (*  pair : 'a Gen.t -> 'b Gen.t -> ('a * 'b) Gen.t  *)
  let pair g1 g2 =
    Gen (fun rs ->
           let rs,rs' = random_split rs in
           let n1 = run_gen rs g1 in
           let n2 = run_gen rs' g2 in (* FIXME: split randomness source w/splitmix *)
           (interleave (Tree.map (fun i1 i2 -> (i1,i2)) n1) n2))

  (*  noshrink : 'a Gen.t -> 'a Gen.t  *)
  let noshrink (Gen g) =
    Gen (fun rs ->
          let Node (a,_) = g rs in
          Node (a,Seq.empty))

  (*  either : 'a Gen.t -> 'a Gen.t -> 'a Gen.t  *)
  let either g1 g2 =
    app
      (map (fun b (t1,t2) -> if b then t1 else t2) bool)
      (pair g1 g2)

  let rec listlen g len = match len with
    | 0 -> return []
    | _ -> app (return (fun (e,es) -> e::es)) (pair g (listlen g (len-1)))

  (*  list : 'a Gen.t -> 'a list Gen.t  *)
  let list g = int_bound 100 >>= listlen g

  (*  generate1 : 'a Gen.t -> 'a  *)
  let generate1 g =
    let rs = Random.State.make_self_init () in
    let Tree.Node (a,_) = run_gen rs g in a
end

type 'a test = {
  count : int;
  name  : string;
  print : 'a Print.t;
  prop  : 'a -> bool;
  gen   : 'a Gen.t;
}

type t = | Test : 'a test -> t

let make_test ?(count=100) name print gen prop = Test { count; name; print; prop; gen }

(*  check_integrated : t -> Random.State.t -> unit  *)
let check_integrated (Test { count; name; print; prop; gen }) rngstate =
  let rec shrink_loop p seq print acc =
  match seq () with
  | Seq.Nil -> acc
  | Seq.Cons (Tree.Node (a',shks),seq') ->
    if p a'
    then (* a' holds, discard shks-subtree - try seq' instead *)      
      shrink_loop p seq' print acc
    else (* a' doesn't hold, visit shks subtree. *)
      shrink_loop p shks print (Some a')
  in
  let rec test_loop remaining = match remaining with
    | 0 -> Printf.printf "\n  (%i/%i) Success - no counterexample found\n" count count;
    | _ ->
      let Tree.Node (a, rest) = Gen.run_gen rngstate gen in
      print_string "#";
      flush stdout;
      match prop a with
       | true -> test_loop (remaining-1)
       | false ->
          let num_tests = 1+count-remaining in
          print_newline ();
          Printf.printf "  Failed! Property failed after %i tests\n" num_tests;
          Printf.printf "  Initial counterexample: %s\n" (print a);
          flush stdout;
          match shrink_loop prop rest print None with
           | None   -> Printf.printf "  Shrinking finished without finding a smaller counterexample\n"
           | Some x -> Printf.printf "  Shrunk counterexample: %s\n" (print x)
  in
  Printf.printf ("\nTest \"%s\": ") name;
  test_loop count

(*  test_runner : test list -> unit *)
let test_runner ts = 
  let rs = Random.State.make_self_init () in
  List.iter (fun t -> check_integrated t rs) ts
