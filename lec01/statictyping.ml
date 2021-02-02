(* OCaml is statically typed:
   It checks types at compile time,
   which means errors are discovered and prevented before the code gets to run *)
let somestr = "abc";;
print_endline somestr;;
print_endline (somestr ^ "def");;
print_endline ("I know my " ^ somstr) (*typo -> compile-time type error*)
