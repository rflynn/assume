# ex: set ts=8 noet:

CFLAGS=-W -Wall -Wno-unused -pedantic -std=c99
BIN=types values nfa

all: $(BIN)

types: types.o
values: values.o
nfa: nfa.o

clean:
	$(RM) $(BIN) *.o

