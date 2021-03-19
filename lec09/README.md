Lecture 10: Inference rules, Curry-Howard, program generation, and compiler testing
===================================================================================

As exercises consider the following:

  1. Construct a derivation tree proving

     ```
       Gamma |- fun x -> (x, x) : int -> int * int
     ```

  2. Download/clone the generator.

     Check that you can compile it.

     Revise the generator of integer literals in `lit_gen`
     from using `small_signed_int` to have some chance of generating bigger integers
     and integer corner cases.


  3. Change `shuffle_l` to a weighted shuffle

       ```
         val shuffle_w_l : (int * 'a) list -> 'a list QCheck.Gen.t
       ```
     to increase the chance of selecting the `indir_rule`


  4. In some cases the shrinker's output is sub-optimal:

     ```
     Test backend equiv test failed (161 shrink steps):

     Some ((let y = "" in ((let s = (int_of_string y) in (fun v -> 0))
     (let p = (print_endline "") in (let o = "" in (fun l -> (int_of_string o)))))))
     ```

     Here replacing variable `y` with its value "" and variable `o` with its value ""
     would allow their let-bindings to be removed:

     ```
     Some (((let s = (int_of_string "") in (fun v -> 0) (let p = (print_endline "") in
     (fun l -> (int_of_string ""))))))
     ```

     Write a recursive function

     ```
       (*  subst_lit : string -> lit -> exp -> exp  *)
       let subst_lit x l e' = ...
     ```

     that substitutes all occurrences of `Var x` in `e'` with `l`:
     ```
       subst_lit "x" (Intlit 5) (Var "x") = (Lit (Intlit 5))
     ```
     be careful to not touch rebindings of `x`:
     ```
       subst_lit "x" (Intlit 5) (Lam ("x", Var "x")) = (Lam ("x", Var "x"))
     ```
    
     Now use `subst_lit` to improve the shrinker to rewrite
     ```
       let x = l in e'   into   subst_lit x l e'
     ```

  5. (for the brave)
     Add a `char` type, `char` literals, and some `char` functions from the standard library
     such as:
     ```
       val print_char : char -> unit
       val char_of_int : int -> char
       val int_of_char : char -> int
     ```

In any remaining time this afternoon I suggest you work on your projects. 

You are also welcome to play with the program generator.
