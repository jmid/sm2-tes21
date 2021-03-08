lec06:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show lec06.native

putget: putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,qcstm,ppx_deriving.show -lflags putgetlib.o putget.native

putgetprint: putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,qcstm,ppx_deriving.show -lflags putgetlib.o putgetprint.native

putgetcomp: putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,qcstm,ppx_deriving.show -lflags putgetlib.o putgetcomp.native

putgetlib.o: putgetlib.c
	ocamlbuild putgetlib.o

putgetlib.so: putgetlib.c
	if [[ ! -d _build ]]; then mkdir _build; fi
	gcc -shared -o _build/putgetlib.so -fPIC putgetlib.c

clean:
	ocamlbuild -clean
	rm -f tmp.c tmp tmp.stdout tmp.stderr
