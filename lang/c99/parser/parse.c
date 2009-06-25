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
  const struct lexeme *l;
  struct token *next;
};
typedef struct token tok;

/**
 * all of these elements have their own namespaces
 */
enum ns {
  NS_ENUM,
  NS_STRUCT,
  NS_UNION,
  NS_TYPE,
  NS_SYM,
  NS_CNT
};

/**
 * file-scope symbol tables
 */
static struct token * Namespace[NS_CNT];

static struct token * ns_get(enum ns n, const struct lexeme *l)
{
  struct token *s = Namespace[n];
  while (s && !lexeme_cmp(l, s->l))
    s = s->next;
  }
  return s;
}

static int ns_add(enum ns n, const struct lexeme *l)
{
  struct token *t = ns_get(n, l);
  int added = 0;
  if (!t) {
    t = malloc(t);
    if (t) {
      t->l = l;
      t->next = Namespace + n;
      Namespace[n] = t;
      added = 1;
    }
  }
  return added;
}

/**
 * match char
 */
static int c(const char c, const struct token *t)
{
  return 1 == t->l->len && c == t->l->str[0];
}

/**
 * match token type
 */
static int t(enum token tok, const struct token *t)
{
  return tok == t->l->tok;
}

enum {
  P_STORAGE_CLASS_SPEC = T_CNT,
  P_TYPE_SPEC,
  P_CNT
};

enum postfix_expr {
  PRI_EXPR,   /* primary_expr                        */
  PF_INDEX,   /* postfix_expr '[' expr           ']' */
  PF_CALL,    /* postfix_expr '(' arg_expr_list? ')' */
  PF_MEMBER,  /* postfix_expr '.' ident              */
  PF_PTR,     /* postfix_expr "->" ident             */
  PF_INC,     /* postfix_expr "++"                   */
  PF_DEC      /* postfix_expr "--"                   */
};

struct node {
  int type;
  union {
    struct token *t;
    struct {
      struct node *expr;
    } primary_expr;
    struct {
      enum postfix_expr type;
      union {
        struct node *pri;
        struct 
      } v;
    } postfix_expr;
  } v;
};

static int storage_class_specifier(const struct token *t)
{
  return
       t(t, T_TYPEDEF)
    || t(t, T_EXTERN)
    || t(t, T_STATIC)
    || t(t, T_AUTO);
}


static void tokenlist_show(const struct token *t)
{
  while (t) {
    lexeme_show(t->l);
    t = t->next;
  }
}

/**
 * token list references only those
 * lexemes to be considered for parsing
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
        t->l = l;
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

