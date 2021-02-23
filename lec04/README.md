Lecture 4: Modules, shrinking, and model-based testing of Patricia trees
------------------------------------------------------------------------

As exercises I ask you to consider the following:

1. Consider the following module implementing `(string,int)`
   dictionaries as in Hickey, exercise 3.6:
   ```
    module Dict =
    struct
      type key = string
      type value = int
      type dictionary = key -> value
      let empty key = 0
      let add dict key v =
        fun key' -> if key=key' then v else dict key'
      let find dict key = dict key
    end
   ```
   Write an interface for the module, such that the dictionary type is
   abstract (hidden) to outsiders.

   Tip: If you choose to write separate files `dict.mli` and `dict.ml`
   containing the interface and the implementation, the console command
   ```
     ocamlc dict.mli dict.ml
   ```
   compiles the source code into two files `dict.cmi` and `dict.cmo`.
   You can then load the compiled `Dict` module into utop using
   ```
      #load "dict.cmo";;
   ```

   (after module slides)


2. a. Fix `myshr` so that it doesn't make QCheck loop (Ctrl-C stops it):
      ```
        let myshr i = Iter.return (i/2);;
        let t = Test.make (set_shrink myshr int) (fun i -> false);;
        QCheck_runner.run_tests [t];;
      ```
   b. Try the above on other false properties, e.g., `(fun i -> i < 432)`
      How does it behave on different runs?
      Can you improve the shrinking strategy?

      (after shrinking+iterator slides)


3. Consider the following test that uses the built-in `pair` generator and shrinker:
     ```
       let t = Test.make (pair small_nat small_nat) (fun (i,j) -> i+j = 0);;
       QCheck_runner.run_tests ~verbose:true [t];;
      ```

   Despite randomization QCheck's pair shrinker produces the same two reduced counterexamples. Which?
   One of the counterexamples is reported more often that the other. Why?


4. a. Formulate in words a more aggressive shrinking strategy for
      arithmetic expressions. (If you were to simplify such test-input
      by hand how would you proceed?)

   b. Implement the strategy and test how well it works
      (how much it simplifies, how many steps it uses, how consistent
      it is) compared to the one I proposed for different false
      properties such as the following three:
      ```
        (fun (xval,e) -> interpret xval e = xval)
        (fun (xval,e) -> interpret xval (Plus(e,e)) = interpret xval e)
        (fun (xval,xval',e) -> interpret xval e = interpret xval' e)
      ```
 
      To make sure you are comparing the shrinkers over identical runs,
      use, e.g.,  `QCheck_runner.set_seed : int -> unit`


5. a. Clone or download the quickcheck code from here
      https://github.com/jmid/qc-ptrees

   b. Compile (run `make old`) and run the code (run `./qctest.native`)
      to ensure that you can recreate the issue.

   c. Extend the testsuite with tests for the following API operations:
      ```
        val is_empty : t -> bool
        val diff     : t -> t -> t
        val equal    : t -> t -> bool
        val subset   : t -> t -> bool
      ```

      (For which ones is it necessary to extend the generator?)


6. (for the brave)

   a. Formulate in words a shrinking strategy for lists.
      (How would you combine it with the element shrinker?)

   b. Implement the strategy and test how well it works
      (how much it simplifies, how many steps it uses)
      compared to the builtin list shrinker, for some false properties
      over lists, e.g., `(fun es -> List.reverse es = es)`
                    and `(fun es -> List.length es < 42)`
