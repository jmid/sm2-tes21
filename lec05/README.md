Lecture 5: Model-based testing of stateful code with a state-machine framework
------------------------------------------------------------------------------

The QCSTM state machine framework can be installed through opam with the command
   ```
    opam install qcstm
   ```

The source code for QCSTM and additional examples are available here: https://github.com/jmid/qcstm

Much of today's code also utilizes the opam package `ppx_deriving` for automatically deriving to-string functions.

When editing code in VS Code using `ppx_deriving.show` you need to
inform merlin about the dependency. Simply edit the `.merlin`-file to
list it along with `qcheck`:
```
  PKG qcheck ppx_deriving.show
```

Similarly if your code depends on `qcstm` you will also have to list it as a dependency in the `.merlin`-file.


As exercises consider the following:

1. Install `ppx_deriving` via opam:
   ```
     opam install ppx_deriving
   ```
   
   Load it into utop with `#require "ppx_deriving.show";;`

   What is the difference between the derived printers
     ```
       H1.show_cmd : H1.cmd -> string
     ```
   and
     ```
       H2.show_cmd : H2.cmd -> string
     ```
   resulting from the following two module declarations?
     ```
       module H1 =
       struct
         type cmd =
           | Add of string * int
           | Remove of string
           | Find of string
           | Mem of string [@@deriving show]
       end
     
       module H2 =
       struct
         type cmd =
           | Add of string * int
           | Remove of string
           | Find of string
           | Mem of string [@@deriving show { with_path = false }]
       end
     ```

2. What property are we testing the hashtable for?
   Phrase it in your own words.


3. Download the hashtable model in [lec05/hashtable.ml](lec05/hashtable.ml)
   (really: clone/checkout the whole repository https://gitlab.sdu.dk/jmid/sm2-tes21 )
   and ensure that you can compile it with `make hashtable` in the [lec05](lec05) folder
   (you will need to `opam install qcstm`) and run it. 

   Inject another error in the model (ignore a specific key, duplicate
   an entry, ...) and see if the error is caught by the tests.

   Can you inject an error which is not caught by the tests?
   If so, why? - and can we patch the tests to catch it? 


4. Queues from the standard library also has a length operation:
   ```
     val length : 'a t -> int
   ```
   
   http://caml.inria.fr/pub/docs/manual-ocaml/libref/Queue.html

   Extend the model-based test with the `length` operation.
   You will need to extend the `cmd` type, the `cmd` generator, the two
   interpreters `next_state` and `run_cmd`, and `precond`.


5. A classic way to implement a queue is using two (singly-linked) lists:
   * One list represents the front, the other list represents the back.
   * This way you remove entries from one (front) and add them to the other (back).
   * If the front runs out, we reverse the back and use that as our new front.
 
   Implement the Queue signature (create, pop, top, push) using this approach.

   For an imperative implementation you can use a reference to a pair: 
   ```
    type myqueue = (int list * int list) ref
   ```

   Test your implementation by adapting our state-machine model.
