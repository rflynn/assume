/* ex: set ts=2 et: */
/*
 * input: lex
 * output: structured c
 */

#define CPPTEST foo\
bar

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "lex.h"

/**
 * subset of lexemes
 */
struct token {
  const struct lexeme *lexeme;
  struct token *next;
};

static void tokenlist_show(const struct token *t)
{
  while (t) {
    lexeme_show(t->lexeme);
    t = t->next;
  }
}

/**
 * produce a list of "tokens" that reference the original
 * lexemes, only those that are not whitespace.
 */
struct token * tokenize(const struct lexeme *l)
{
  struct token *head = NULL;
  struct token *tail = NULL;
  while (l) {
    if (l->tok != T_SPACE && l->tok != T_NEWLINE) {
      struct token *t;
      t = malloc(sizeof *t);
      if (t) {
        t->lexeme = l;
        if (!head)
          head = t;
        if (tail)
          tail->next = t;
        tail = t;
      }
    }
    l = l->next;
  }
  if (tail)
    tail->next = NULL;
  return head;
}

int main(void)
{
  struct lexeme *l;
  struct token *t;
  l = NULL;
  lex_init();
  (void)lex_file(stdin, &l);
  t = tokenize(l);
  tokenlist_show(t);
  return 0;
}

