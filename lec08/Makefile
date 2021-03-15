aexp:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show,bisect_ppx aexp.native
	BISECT_COVERAGE=YES ./aexp.native
	bisect-ppx-report html

fac:
	ocamlbuild -use-ocamlfind -package bisect_ppx fac.native
	BISECT_COVERAGE=YES ./fac.native
	bisect-ppx-report html

lec08:
	ocamlbuild -use-ocamlfind -package qcheck lec08.byte
	ocamlbuild -use-ocamlfind -package qcheck lec08.cma

stmtlang:
	ocamlbuild -use-ocamlfind -package qcheck stmtlang.native
	ocamlbuild -use-ocamlfind -package qcheck stmtlang.cma

clean:
	ocamlbuild -clean
	rm -f tmp.bc output.txt bisect*.coverage
