# ex: set ts=8 noet:

CFLAGS= -Os -W -Wall -Werror -pedantic -g -std=c89 
LDFLAGS = -g

all: lex parse

lex:
	$(RM) lex.o
	$(CC) $(CFLAGS) -DTEST $(LDFLAGS) -o lex lex.c

parse:
	$(RM) lex.o
	$(CC) $(CFLAGS) $(LDFLAGS) -c lex.c
	$(CC) $(CFLAGS) -DTEST $(LDFLAGS) -o parse parse.c lex.o

clean:
	$(RM) parse lex *.o

