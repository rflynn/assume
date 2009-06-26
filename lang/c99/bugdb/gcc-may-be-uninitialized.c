/*
 * GCC nicely tries to detect cases where a variable may be read before it
 * is written. However, it's too stupid to really figure out what's going on.
 *
 * Here's what I get:
 * lex.c: In function 'match_one':
 * lex.c:338: error: 'longl' may be used uninitialized in this function
 *
 * Here's the original function:

static int match_one(const char *buf, size_t buflen, struct lexeme *t)
{
  t->tok = T;
  if (buflen > 0) {
    unsigned i = 0;
    unsigned longl;
    int c = *buf;
    regoff_t longest = 0;
    while (i < Match[c].cnt) {
      regmatch_t m[4];
      int l, r;
      l = Match[c].lexeme[i];
      r = regexec(&Lexeme[l].rgx, buf, sizeof m / sizeof m[0], m, 0);
      if (r != REG_NOMATCH) {
        int len = m[0].rm_eo;
        if (0 != m[0].rm_so || 0 == len) {
          fprintf(stderr, "expect offset=0 len>0. instead, offset=%d len=%d",
            m[0].rm_so, len);
          exit(1);
        }
        assert((size_t)len <= buflen && "match ran off the end of buf(!)");
        if (len > longest) {
          longest = len;
          longl = l;
        }
      }
      i++;
    }
    if (longest > 0) {
      t->tok = longl;
      t->len = longest;
      t->str = buf;
    }
  }
  return t->tok != T;
}

 *
 * Except that particular read of 'longl' could never be uninitialized, because
 * of longl's relationship to another variable, 'longest'. If 
 *
 * This is my attempt to recreate the situation, although it doesn't work...
 */

#include <stdlib.h>
int main(void)
{
  int r = 0; /* return value */
  int a = 0; /* a and b are always used together */
  int b;     /* uninitialized */
  /* block in which b may be set */
  if (rand() > 0)
    a = 1, b = 1; /* only place a can be != 0, b also set */
  if (a > 0) /* if this is true then b is initialized */
    r = b;   /* this can never be uninitialized because of a and b's relationship */
  return b;
}

