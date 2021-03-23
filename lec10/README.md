Lecture 10: Race Condition Testing with Parallel State Machines, Stack-Driven Program Generation of WebAssembly, Integrated shrinking
=======================================================================================================================================

1. [intqc.ml](intqc.ml) contains a proof-of-concept integrated shrinking library for OCaml.

   Download/clone the repository and try one the following:
   
   * Run the examples from the console:
     ```
      make tests
      ./tests.byte
     ```

     Load the compiled code and example tests into utop: First run `make`, then in utop:
     ```
      #load "intqc.cmo";;
      open Intqc;;
      #use "tests.ml";;
     ```

   * Write an example test directly in utop (after compiling and loading `intqc` as above):
     ```
      utop # open Intqc;;
      utop # let t = make_test ~count:1000 "mytest" Print.(list int) Gen.(list int) (fun xs -> List.length xs < 3);;
      val t : t =
      Test
       {count = 1000; name = "mytest"; print = <fun>; prop = <fun>;
        gen = Intqc.Gen.Gen <fun>}
      utop # test_runner [t];;

      Test "mytest": #
        Failed! Property failed after 1 tests
        Initial counterexample: [991231154; 855765311; 1029602260; 891777431; 440935742; 212764799; 1049944962; 609063290; 446664073; 608795706; 447589352; 122712157; 206104746; 332638411; 663534370; 212389030; 962880438; 590811428; 679968236; 718497387; 460161629; 806444868; 531558584; 238744055; 1020966983; 1002541815; 254037912; 852895204; 635960144; 945209323; 1057655328; 705156619; 837189438; 138746059; 543955551; 790471504; 890463248; 369611743; 177544647; 871180291; 505513876; 554852316; 228017859; 556788993; 414492679; 905010328; 956559603; 1028379233; 699992430; 947278671; 268361551; 224268270; 20034259; 141302295; 515057669; 276923981; 376100267; 463225287; 21967031; 855173082; 192113322; 246311346; 603731037; 56693128; 212947853; 980920214; 316929951; 991018336; 559850119]
        Shrunk counterexample: [0; 0; 0]
      - : unit = ()
     ```

   * Inspect the generated shrink trees. On my machine this generates `true` and `3` as well as their combined `pair` tree. 
     It also prints out all 3 three trees up to depth 5 (the tree printer could be better...):
     ```
      let bool_tree = (* generate true and its shrink tree *)
        let rs = Random.State.make [|0;1;2|] in
        Gen.run_gen rs Gen.bool
      ;;
      Tree.print_depth Print.bool bool_tree 5 |> print_endline
      ;;
      let int_tree = (* generate 3 and its shrink tree *)
        let rs = Random.State.make [|5|] in
        Gen.run_gen rs (Gen.int_bound 5)
      ;;
      Tree.print_depth Print.int int_tree 5 |> print_endline
      ;;
      let pair_tree = Gen.interleave (Tree.map (fun i1 i2 -> (i1,i2)) bool_tree) int_tree
      ;;
      Tree.print_depth Print.(pair bool int) pair_tree 5 |> print_endline;;
     ```

2. In any remaining time: discuss and decide on a project topic and write a short project description
   (if you haven't already done so). You are also welcome play with the `intqc`-module and try it on various examples.



Resources on integrated shrinking:
----------------------------------

 - An early design thread on the Haskell mailing list: https://mail.haskell.org/pipermail/libraries/2013-November/021674.html
 - A Reddit thread where Koen Claessen chips in: https://www.reddit.com/r/haskell/comments/646k3d/ann_hedgehog_property_testing/
 - A talk by Jacob Stanley on Hedgehog's design: https://www.youtube.com/watch?v=AIv_9T0xKEo
 - A blog post by Edsko de Vries with pro/cons: https://www.well-typed.com/blog/2019/05/integrated-shrinking/

Python's Hypothesis library takes a different path to integrated shrinking, 
 - described in this paper: https://www.doc.ic.ac.uk/~afd/homepages/papers/pdfs/2020/ECOOP_Hypothesis.pdf
 - advocated here: https://hypothesis.works/articles/integrated-shrinking/
