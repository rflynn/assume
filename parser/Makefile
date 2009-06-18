# ex: set ts=8 noet:

OCAMLC=ocamlc
LEX=ocamllex
YACC=ocamlyacc

all: parse lex
	$(OCAMLC) -c lex.ml
	$(OCAMLC) -c c99.ml
	$(OCAMLC) -c main.ml
	$(OCAMLC) -o c99 lex.cmo c99.cmo main.cmo

parse:
	$(YACC) -v c99.mly
	$(OCAMLC) -c c99.mli

lex:
	$(LEX) lex.mll

test: all
	./test-lex.sh

clean:
	$(RM) c99 *.cm{i,o} lex.ml c99.{ml,mli,output}

