/*
 * grammar generator.
 * grammar hard-coded for simplicity.
 */

#include <stdio.h>
#include <stdlib.h>

struct term
{
  enum t { T, N } t;
  union
  {
    const struct list *nont;
    const char * const term;
  } val;
};

struct list
{
  unsigned len;
  struct term term[3];
};

/**
 * hardcoded simple but not trivial binary arithmetic grammar
 */
static const struct list Val   = { 3u, { { T, .val.term = "0"   }, { T, .val.term = "1"    }, { N, .val.nont = &Val  } } };
static const struct list Op    = { 2u, { { T, .val.term = "+"   }, { T, .val.term = "-"    }                           } };
static const struct list OpVal = { 2u, { { N, .val.nont = &Op   }, { N, .val.nont = &Val   }                           } };
static const struct list Expr;
static const struct list EOE   = { 3u, { { N, .val.nont = &Expr }, { N, .val.nont = &Op    }, { N, .val.nont = &Expr } } };
static const struct list Expr  = { 3u, { { N, .val.nont = &Val  }, { N, .val.nont = &OpVal }, { N, .val.nont = &EOE  } } };

struct m
{
  const struct list *l;
  unsigned index;
};

static void printmatch(const struct m *m, unsigned cnt)
{
  unsigned i = 0u;
  printf("match:\n");
  while (i < cnt)
  {
    if (T == l.term[i].t)
      printf(" m[%u] = \"%s\"\n", i, l.term[i].val.term);
    i++;
  }
}

static void domatch(const struct list *root, unsigned cnt, struct m *m)
{
  if (cnt > 0u) {
    const struct list *curr = root;
    while (cnt) {
      cnt--;
    }
  }
}

/**
 * find all matches of size 'cnt'
 */
static void match(const struct list *root, unsigned cnt)
{
  if (cnt > 0u) {
    struct m *m = malloc(cnt * sizeof(*m));
    if (m) {
      memset(m, 0, cnt * sizeof(*m));
      m[0].l = root;
      m[0].index = 0u;
      domatch(root, cnt, m);
      free(m);
    }
  }
}

int main(void)
{
  match(&Expr, 1);
  return 0;
}


