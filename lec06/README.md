Lecture 6: Case study: LevelDB + code in other languages, tail-calls, function generation, more on properties
=============================================================================================================

The put/get examples again requires the QCSTM state machine framework (`opam install qcstm`)
which is available here: https://github.com/jmid/qcstm

[putget.ml](putget.ml) requires the `ctypes` and `ctypes-foreign` packages (`opam install ctypes ctypes-foreign`)

[putgetcomp.ml](putgetcomp.ml) requires the `gcc` C compiler to be installed (but others, e.g., `clang` could work too).


As exercises consider the following:

1. Compile and run [putget.ml](putget.ml) with `make putget`

   You'll need to install `qcstm`, `ctypes`, and `ctypes-foreign` via OPAM

   If you change the injected bug in `putgetlib.c`,
   can the tests still find it?

   Extend `putget.ml` so that it also can generate `reset` commands.
   (You'll need to extend the `cmd` type, the `cmd` generator, and the two
   `cmd` interpreters `next_state` and `run_cmd`)


2. a. Consider the following recursive function
  
        let rec member xs y = match xs with
          | [] -> false
          | x::xs -> x=y || member xs y
 
      Discuss whether it requires `|xs|` or constant stack space, i.e., is it "tail recursive"?

   b. Check your answer to (a.) by using

        Gen.list_size : int Gen.t -> 'a Gen.t -> 'a list Gen.t

      For example, this generates a 1.000.000 element list:
      
        Gen.(generate1 (list_size (int_bound 1_000_000) small_nat));;

   c. Consider the following recursive functions:

        let rec fac n = match n with
          | 0 -> 1
          | _ -> n * fac (n-1)
        
        let rec reverse xs = match xs with
          | [] -> []
          | x::xs -> (reverse xs) @ [x]
	  
      Both are non-tail recursive: `fac` requires `n` stack frames and
      `reverse` requires `|xs|` stack frames (and even has quadratic time complexity).

      Write equivalent tail-recursive versions using an accumulator,
      and requiring only constant stack space.

      Test your code for agreement with property-based tests.

      Check that the new versions do not run out of stack space for large input.


3. Test `List.map`
   - which property should hold for it?
   - phrase a function generator and property-based tests for it


4. Study another QuickCheck framework of your choice (JavaScript, Python,
   C++, Scala, F#, Erlang, Haskell, ...).

   Here are links to some relatively good ones:

   - Quviq QuickCheck (http://www.quviq.com/downloads/) for Erlang
      (There's a free 'mini' version for download + you can use the
       full commercial version on open source code via Travis/Jenkins/...)
   - Proper (https://proper-testing.github.io/) for Erlang  
   - ScalaCheck (https://www.scalacheck.org/) for Scala  
   - Hedgehog (https://github.com/hedgehogqa) for F#, Scala, Haskell, and R
   - FsCheck (https://fscheck.github.io/FsCheck/) for .NET (F# and C#)
   - Hypothesis (https://github.com/HypothesisWorks/hypothesis) for Python (Ruby and Java)
   - fast-check (https://github.com/dubzzz/fast-check) for JavaScript/TypeScript
   - JSVerify (http://jsverify.github.io/) for JavaScript
   - Lua-QuickCheck (https://github.com/luc-tielen/lua-quickcheck) for Lua  
   - RapidCheck (https://github.com/emil-e/rapidcheck) for C++
   - ...
   
   but there is bound to be others:

     - try searching https://github.com for 'quickcheck' or 'property-based testing'
     - http://lmgtfy.com/?q=property-based+testing
     - look at Wikipedia's entry https://en.wikipedia.org/wiki/QuickCheck
       (potentially a good source - but not necessarily. The last time I looked
        the listed OCaml entry was very out of date.)
     - look at http://hypothesis.works/articles/quickcheck-in-every-language/

   Now:
   - Install it
   - How easy is it to express some of the examples we have covered?
   - How well does the builtin generators (int, list, ...) work?
   - Does the framework support shrinking, statistics, ...?
   - Does it have a state machine framework for model-based testing?
     If so: how easy is it/how well does it work?
   - Prepare a short presentation of the framework based on your findings
     for next time
