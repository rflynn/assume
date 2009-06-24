# ex: set ts=8 noet:

CFLAGS= -Os -W -Wall -Werror -pedantic -g -std=c89 
LDFLAGS = -g

parse:
	$(RM) lex.o
	$(CC) $(CFLAGS) $(LDFLAGS) -c lex.c
	$(CC) $(CFLAGS) -DTEST $(LDFLAGS) -o parse parse.c lex.o

lex:
	$(RM) lex.o
	$(CC) $(CFLAGS) -DTEST $(LDFLAGS) -o lex lex.c

clean:
	$(RM) parse lex *.o

