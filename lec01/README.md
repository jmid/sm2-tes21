Lecture 1: Installation, OCaml, QCheck, BNF grammars
====================================================

Belows follows a number of exercises for this afternoon.

0. Install OCaml, OPAM, QCheck, and VS Code according to the [installation guide](../INSTALL.md)

1. Consider the following BNF grammar for a subset of English:
   ```
      (sentence)    S  ::=  NP VP
   (noun phrase)   NP  ::=  the N
   (verb phrase)   VP  ::=  V NP
          (noun)    N  ::=  student  |  lecturer  |  laptop  |  cat  |  song  |  book
          (verb)    V  ::=  found  |  shot  |  broke  |  ate  |  saw  |  rebooted
    ```
    Derive two sentences from it: a meaningful one and a silly one

2. What is the result of evaluating the following comparisons?
   ```
     0 = 0
     0 <> 0
     0l = 0l
     0l <> 0l
   ```
   
3. OCaml also supports the alternative `==` and `!=` comparison operations.
   What is the result of evaluating the following comparisons?
   ```
     0 == 0
     0 != 0
     0l == 0l
     0l != 0l
   ```
     Why?

4. What is the result of evaluating the expression
   ```
      "I love QuickCheck " ^ 2
   ```
   compared to the following Java expression?
   ```
      "I love QuickCheck " + 2
   ```
   How would you express the latter in (legal) OCaml?

5. Implement the following three functions:

    ```
      cube : int -> int

        the function should return the cube of its argument,
        so that cube 2 returns 8, cube 3 returns 27, ...
   
      is_even : int -> bool

        is_even returns a Boolean indicating whether the argument is
        divisible by 2, e.g., is_even 2 returns true, is_even 41 returns
        false.
   
      quadroot : float -> float

        rather than the square root, quadroot should return the fourth
        root of its argument, i.e., a number which raised to the fourth
        power gives the argument. For example: quadroot 16. returns 2.,
        quadroot 4.0 returns 1.41421...
    ```

6. Exercise 3.1 (1-9) in Hickey
