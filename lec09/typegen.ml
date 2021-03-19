open QCheck

(** Data type, to_string, and pure generator for types **)

type typ =
  | Unit
  | Int
  | String
  | Fun of typ * typ

let rec typ_to_string t = match t with
  | Unit   -> "unit"
  | Int    -> "int"
  | String -> "string"
  | Fun (t,t') -> "(" ^ typ_to_string t ^ " -> " ^ typ_to_string t' ^ ")"

let leaf_gen = Gen.oneofl [Unit; Int; String]
let typ_gen = Gen.(sized (fix (fun rgen n -> match n with
    | 0 -> leaf_gen
    | _ ->
      oneof
        [leaf_gen;
         map2 (fun t t' -> Fun(t,t')) (rgen (n/2)) (rgen (n/2))]
    )))


(** Data type, to_string, and pure generator for literals **)

type lit =
  | Unitlit
  | Intlit of int
  | Strlit of string

let lit_to_string l = match l with
  | Unitlit  -> "()"
  | Intlit i ->
    let s = string_of_int i in    (* put parens around negative ints *)
    if i < 0 then "(" ^ s ^ ")" else s
  | Strlit s -> "\"" ^ String.escaped s ^ "\""   (* escape strings *)

open Gen

(*  lit_gen : typ -> (lit option) Gen.t  *)
let lit_gen t = match t with
  | Unit   -> return (Some Unitlit)
  | Int    -> map (fun i -> Some (Intlit i)) small_signed_int
  | String -> let str_gen = string_size ~gen:printable small_nat in
              map (fun s -> Some (Strlit s)) str_gen
  | Fun (_,_) -> return None


(** Data type, generator, and to_string for expressions **)

type exp =
  | Lit of lit
  | Var of string
  | Lam of string * exp
  | App of exp * exp
  | Let of string * exp * exp
  | Indir of string * exp list

let rec exp_to_string e = match e with
  | Lit l -> lit_to_string l
  | Var x -> x
  | Lam (x,e) -> "(fun " ^ x ^ " -> " ^ exp_to_string e ^ ")"
  | App (f,arg) -> "(" ^ exp_to_string f ^ " " ^ exp_to_string arg ^ ")"
  | Let (x,e,e') -> "(let " ^ x ^ " = " ^ exp_to_string e ^ " in " ^ exp_to_string e' ^ ")"
  | Indir (f,es) -> "(" ^ f ^ " " ^ (String.concat " " (List.map exp_to_string es)) ^ ")"

let var_gen = map (fun c -> String.make 1 c) (char_range 'a' 'z')

let uniq_env env =
  let uniq_vars = List.sort_uniq String.compare (List.map fst env) in
  List.map (fun x -> (x,List.assoc x env)) uniq_vars

let rec collect_args t arg_acc = match t with
  | Unit
  | Int
  | String -> (List.rev arg_acc, t)
  | Fun (t,t') -> collect_args t' (t::arg_acc)

(*  exp_gen : env -> typ -> int -> (exp option) Gen.t  *)
let rec exp_gen env t n =

  (*  const_rule : env -> typ -> (exp option) Gen.t  *)
  let const_rule env t =
    lit_gen t >>= fun res -> match res with
      | None   -> return None
      | Some c -> return (Some (Lit c)) in

  (*  var_rule : env -> typ -> (exp option) Gen.t  *)
  let var_rule env t =
    match List.filter (fun (_,t') -> t=t') (uniq_env env) with
    | []  -> return None
    | env ->
      let vars = List.map fst env in
      map (fun x -> Some (Var x)) (oneofl vars) in

  (*  lam_rule : env -> typ -> (exp option) Gen.t  *)
  let lam_rule env t = match t with
    | Unit
    | Int
    | String -> return None
    | Fun (t1,t2) ->
      var_gen >>= fun x ->
      exp_gen ((x,t1)::env) t2 (n-1) >>= fun res -> match res with
      | None   -> return None
      | Some e -> return (Some (Lam (x,e))) in

  (*  app_rule : env -> typ -> (exp option) Gen.t  *)
  let app_rule env t =
    typ_gen >>= fun t1 ->
    exp_gen env (Fun (t1,t)) (n/2) >>= fun res -> match res with
    | None    -> return None
    | Some e0 ->
      exp_gen env t1 (n/2) >>= fun res -> match res with
      | None    -> return None
      | Some e1 -> return (Some (App (e0,e1))) in

  (*  let_rule : env -> typ -> (exp option) Gen.t  *)
  let let_rule env t =
    pair var_gen typ_gen >>= fun (x,t0) ->
    exp_gen env t0 (n/2) >>= fun res -> match res with
    | None    -> return None
    | Some e0 ->
        exp_gen ((x,t0)::env) t (n/2) >>= fun res -> match res with
        | None    -> return None
        | Some e1 -> return (Some (Let (x,e0,e1))) in

  (*  indir_rule : env -> typ -> (exp option) Gen.t  *)
  let indir_rule env t =
    let fenv = List.map (fun (x,t) -> (x, collect_args t [])) (uniq_env env) in
    match List.filter (fun (x,(args,ret)) -> args <> [] && ret = t) fenv with
    | []   -> return None
    | fenv -> 
      oneofl fenv >>= fun (f,(ts,t)) ->
      let arglen = List.length ts in
      let gen_list = List.map (fun ti -> exp_gen env ti (n/arglen)) ts in
      flatten_l gen_list >>= fun res ->
      if List.mem None res
      then return None
      else
        let exps = List.filter_map (fun e -> e) res in (*keep only Some's*)
        return (Some (Indir (f,exps)))
  in

  let rules = match n with
    | 0 -> [const_rule; var_rule]
    | _ -> [const_rule; var_rule; lam_rule; app_rule; let_rule; indir_rule] in
(*  | _ -> [const_rule; var_rule; lam_rule; app_rule; let_rule] in *)(* to disable indir_rule *)

  let rec try_each_loop rules = match rules with
    | [] -> return None
    | rule::rest ->
      rule env t >>= fun res -> match res with
      | None -> try_each_loop rest
      | _    -> return res in

  (*oneofl rules >>= fun rule -> rule env t*)  (* without backtracking *)
  shuffle_l rules >>= try_each_loop            (* with backtracking *)


let init_env =
  [ ("min_int",Int);
    ("max_int",Int);
    ("succ", Fun(Int,Int));
    ("pred", Fun(Int,Int));
    ("string_of_int", Fun(Int,String));
    ("int_of_string", Fun(String,Int));
    ("print_endline", Fun(String,Unit));
    ("print_newline", Fun(Unit,Unit));
    ("(+)",   Fun(Int,Fun(Int,Int)));
    ("(-)",   Fun(Int,Fun(Int,Int)));
    ("( * )", Fun(Int,Fun(Int,Int)));
    ("(/)",   Fun(Int,Fun(Int,Int)));
    ("(mod)", Fun(Int,Fun(Int,Int)));
    ("(^)",   Fun(String,Fun(String,String)));
  ]

let prog_gen =
  pair nat (oneofl [Unit;Int;String]) >>= fun (size,typ) ->
  exp_gen init_env typ size


(** Shrinker **)

let rec occurs x e = match e with
  | Lit _ -> false
  | Var y -> x = y
  | Lam (y,e) -> x <> y && occurs x e
  | App (f,arg) -> occurs x f || occurs x arg
  | Let (y,e,e') -> occurs x e || (x <> y && occurs x e')
  | Indir (f,es) -> x = f || List.exists (fun e -> occurs x e) es

let lit_shrink l = match l with
  | Unitlit  -> Iter.empty
  | Intlit i -> Iter.map (fun i' -> Intlit i') (Shrink.int i)
  | Strlit s -> Iter.map (fun s' -> Strlit s') (Shrink.string s)

let (<+>) = Iter.(<+>)

let rec exp_shrink e = match e with
  | Lit l     -> Iter.map (fun l' -> Lit l') (lit_shrink l)
  | Var x     -> Iter.empty
  | Lam (x,e) -> Iter.map (fun e' -> Lam (x,e')) (exp_shrink e)
  | App (f,arg) ->
    (match f with
     | Lam (x,e) ->
       Iter.return (Let (x,arg,e))
     | Let (x,e,e') when not (occurs x arg) ->
       Iter.return (Let (x,e,App(e',arg)))
     | _ -> Iter.empty)
    <+>
    (match arg with
     | Let (x,e,e') when not (occurs x f) ->
       Iter.return (Let (x,e,App(f,e')))
     | _ -> Iter.empty)
    <+>
    Iter.map (fun f' -> App (f',arg)) (exp_shrink f)
    <+>
    Iter.map (fun arg' -> App (f,arg')) (exp_shrink arg)
  | Let (x,e,e') ->
    (if occurs x e'
     then Iter.empty (* x is used - don't remove *)
     else Iter.return e')
    <+>
    (match e with
     | Let (y,e1,e2) when not (occurs y e') ->
       Iter.return (Let (y,e1, Let (x,e2,e')))
     | _ -> Iter.empty)
    <+>
    Iter.map (fun e'' -> Let (x,e'',e')) (exp_shrink e)
    <+>
    Iter.map (fun e'' -> Let (x,e,e'')) (exp_shrink e')
  | Indir (f,es) ->
    (match List.assoc_opt f init_env with
      | None -> Iter.empty
      | Some t -> match snd (collect_args t []) with
         | Unit   -> Iter.return (Lit (Unitlit)) 
         | Int    -> Iter.return (Lit (Intlit 0))
         | String -> Iter.return (Lit (Strlit ""))
         | _      -> Iter.empty)
    <+>
    Iter.map (fun es' -> Indir (f,es')) (Shrink.list_elems exp_shrink es)

let opt_shrink opt = match opt with
  | None -> Iter.empty
  | Some e -> Iter.map (fun e' -> Some e') (exp_shrink e)

let prog_arb =
  make ~print:(Print.option exp_to_string) ~shrink:opt_shrink prog_gen
