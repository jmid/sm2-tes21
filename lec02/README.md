Lecture 2: Recursive functions, tuples and lists, labeled and optional arguments, testing implication properties
================================================================================================================

As exercises please consider the following:

1. Write a recursive function `msb : int -> int`
   that determines the most significant bit of its argument.
   
   Hint: use repeated right-shifting `lsr` (or division by 2)
   For example

   ```
      msb 5 = 3 (since 5 is represented as ...00101)
      msb 2 = 2 (since 2 is represented as ...00010)
      msb 0 = 0 (since 0 is represented as ...00000)
   ```

   (in class after recursive function slides)


2. Implement `fst` and `snd` with pattern matching

   (in class after pattern-matching slides)


3. Implement the following two functions using recursion and pattern matching:

   - `sum : int list -> int`
     For example:
     ```
         sum [5] = 5
         sum [1;2;3] = 6
     ```


   - `member : 'a list -> 'a -> bool`
     For example:
     ```
         member [5] 3 = false
         member [1;2;3] 2 = true
     ```

     Does your implementation of `member` stop the recursion early
     if the desired element is found?

   (in class after polymorphic lists slides)


4. The `sum` function from above should satisfy the following property
   ```
      sum (xs @ ys) = (sum xs) + (sum ys)
   ```
   for all lists of integers xs and ys.
 
   Write a property-based test that checks it.


5. a. Write a recursive function `merge : int list -> int list -> int list`
      that merges two sorted lists into a new sorted list, e.g.:

      ```
       merge [] [42] = [42]
       merge [1;2;3] [0;0;1;3;7] = [0;0;1;1;2;3;3;7]
      ```

   b. What property should hold of merge?
      ```
       List.sort : ('a -> 'a -> int) -> 'a list -> 'a list
      ```
      from the standard library may be useful here
      (it accepts a comparison function as its first argument, you can just pass it  `compare : 'a -> 'a -> int`)

   c. QuickCheck your implementation of merge based on your answer to b.


6. The standard library comes with operations `Int64.of_int` and `Int64.to_int` for
   transforming an `int` into an `int64` and back again - and similarly for `int32` and `string`.

   Which of the following three "round trip properties" do you expect to hold for an `int i`?

   ```
      i = Int64.to_int (Int64.of_int i)
      i = Int32.to_int (Int32.of_int i)
      i = int_of_string (string_of_int i)
   ```

   Write property-based tests to check them. Can you explain the test results?


7. a. Write an implementation of Euclid's algorithm (Hickey, Ex.3.4, p.25/35)

      Ignore the stuff about writing it as an inline operator,
      just implement a recursive, two-argument function
      ```
        eu_gcd : int -> int -> int
      ```
      we can call as `eu_gcd 15 10`

   b. QuickCheck your implementation against Hickey's algorithm (on p.2/12)

   c. Do they differ?


8. [A Pythagorean triple](https://en.wikipedia.org/wiki/Pythagorean_triple) are integers $`a,b,c`$ such that $`a^2 + b^2 = c^2`$.
   You may remember $`3^2 + 4^2 = 5^2`$ from highschool.

   Write a `QCheck` test that generates integer triples `(a,b,c)` and reports any example triple satisfying $`a^2 + b^2 = c^2`$ as a counterexample.

   Can (you make) your test find other triples than `(3,4,5)`?


9. Test the following different versions of the fibonacci function for
   agreement:
    - the traditional recursive formulation
    - an iterative, bottom-up, linear-time algorithm
    - a sub-linear algorithm (a challenge for the daring)

   See: https://www.nayuki.io/page/fast-fibonacci-algorithms
