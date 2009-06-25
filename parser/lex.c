/* ex: set ts=2 et: */
/*
 * lexer for C99
 */

#define _POSIX_SOURCE /* get stdio.h/fileno() */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <regex.h>
#include <unistd.h>
#include "lex.h"

/* initializer for regex_t */
#ifdef __GNUC__
# define R {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
#else
# define R {0}
#endif

/**
 * forall enum tok
 *  list all pertinent info
 */
static struct {
  enum tok id;
  const char *descr;
  regex_t rgx;
  const char *pattern;
} Lexeme[T_CNT] = {
  /* token        descr        rgx regex-pattern  */
  { T,            "",           R, ""             },
  { T_SPACE,      "ws",         R, "^[ \f\r\t\v]+"},
  { T_NEWLINE,    "nl",         R, "^\n"          },
  { T_COMMENT,    "comment",    R,
  /* TODO: multi-line weird preprocessor comment crap,
   * uncomment the tests from test-lex.sh!
   */
    "^("
      /* C-style comment, like this */
      "/\\*" 
        "("
          "\\*[^/]"                 /* * then anything except /    */
          "|[^*]"                   /* anything but \ and *        */
          ")*"
      "\\*/"
      /* C++ style "//" */
      "|//[^\n]*\n|//[^\n]*" 
    ")"
                                                  },
  
  /* Preprocessor (Ref #1 S6.10 */
  { T_CPP,          "cpp",      R, "^#[ \f\r\t\v]*"         },
  { T_CPP_IFDEF,    "",         R, "^#[ \f\r\t\v]*ifdef"    },
  { T_CPP_IFNDEF,   "",         R, "^#[ \f\r\t\v]*ifndef"   },
  { T_CPP_IF,       "",         R, "^#[ \f\r\t\v]*if"       },
  { T_CPP_ELIF,     "",         R, "^#[ \f\r\t\v]*elif"     },
  { T_CPP_ELSE,     "",         R, "^#[ \f\r\t\v]*else"     },
  { T_CPP_ENDIF,    "",         R, "^#[ \f\r\t\v]*endif"    },
  { T_CPP_INCLUDE,  "",         R, "^#[ \f\r\t\v]*include"  },
  { T_CPP_DEFINE,   "",         R, "^#[ \f\r\t\v]*define"   },
  { T_CPP_UNDEF,    "",         R, "^#[ \f\r\t\v]*undef"    },
  { T_CPP_LINE,     "",         R, "^#[ \f\r\t\v]*line"     },
  { T_CPP_ERROR,    "",         R, "^#[ \f\r\t\v]*error"    },
  { T_CPP_PRAGMA,   "",         R, "^#[ \f\r\t\v]*pragma"   },
  { T_CPP_LINECONT, "",         R, "^\\\\\n"                },
  
  /* constant values */
  { T_CONST_FLOAT,"float_lit",  R,
    "^("
      /* decimal float */
      "("
        "[0-9](\\.[0-9]*)?"         /* 0(.1)?                      */
        "|\\.[0-9]+"                /* .0                          */
       ")"
       "([eE][+-]?[0-9]+)?"         /* exponent                    */
      /* hexadecimal float */
      "|0[xX][[:xdigit:]]+"
        "(\\.[[:xdigit:]]+)?"
        "[pP][+-]?[0-9]+"           /* exponent                    */
    ")"
    "([fF]?[lL]?|[lL][fF])?"        /* suffix                      */
                                                  },
  { T_CONST_INT,  "int_lit",    R,
    "^("
      "0[xX][[:xdigit:]]+"          /* hexadecimal                 */
      "|0[0-7]*"                    /* octal                       */
      "|[1-9][0-9]*"                /* decimal                     */
    ")"
    "[uU]?[lL]?[lL]?"               /* suffix                      */
                                                  },
  { T_CONST_STR,  "str_lit",    R,
    "^"
    "L?"                            /* optional wide string */
      "\""
        "("
          "[^\\\"\n]+"              /* normal char                 */
          "|\\\\[\\\\\"abfnrtv]"      /* escaped special             */
          "|\\\\x[[:xdigit:]]{1,2}" /* hexadecimal escape          */
          "|\\\\0[0-7]{0,2}"        /* octal escape                */
        ")*"
      "\""
                                                  },
  { T_CONST_CHAR,  "char_lit",  R,
    "^"
      "L?"                          /* optional wide char          */
      "'"
        "("
          "[^\\']"                  /* any char except ' or \      */
          "|\\\\[\\\\'abfnrtv]"     /* escaped special             */
          "|\\\\x[[:xdigit:]]{1,2}" /* hexadecimal escape          */
          "|\\\\0[0-7]{0,2}"        /* octal escape                */
        ")*"
      "'"
                                                  },
  { T_IDENT,      "ident",      R,
    "^[_a-zA-Z]"                    /* must start with non-digit   */
    "("
      "[_a-zA-Z0-9]+"               /* continue with alphanum      */
      "|\\\\u[[:xdigit:]]{4}"       /* "small" universal names     */
      "|\\\\U[[:xdigit:]]{8}"       /* "big" ones.                 */
    ")*"
                                                  },
  
  /* Keywords (Ref #1 S6.4.1.1) */
  { T_AUTO,       "keyword",    R, "^auto"        },
  { T_BREAK,      "keyword",    R, "^break"       },
  { T_CASE,       "keyword",    R, "^case"        },
  { T_CHAR,       "keyword",    R, "^char"        },
  { T_CONST,      "keyword",    R, "^const"       },
  { T_CONTINUE,   "keyword",    R, "^continue"    },
  { T_DEFAULT,    "keyword",    R, "^default"     },
  { T_DO,         "keyword",    R, "^do"          },
  { T_DOUBLE,     "keyword",    R, "^double"      },
  { T_ELSE,       "keyword",    R, "^else"        },
  { T_ENUM,       "keyword",    R, "^enum"        },
  { T_EXTERN,     "keyword",    R, "^extern"      },
  { T_FLOAT,      "keyword",    R, "^float"       },
  { T_FOR,        "keyword",    R, "^for"         },
  { T_GOTO,       "keyword",    R, "^goto"        },
  { T_IF,         "keyword",    R, "^if"          },
  { T_INLINE,     "keyword",    R, "^inline"      },
  { T_INT,        "keyword",    R, "^int"         },
  { T_LONG,       "keyword",    R, "^long"        },
  { T_REGISTER,   "keyword",    R, "^register"    },
  { T_RESTRICT,   "keyword",    R, "^restrict"    },
  { T_RETURN,     "keyword",    R, "^return"      },
  { T_SHORT,      "keyword",    R, "^short"       },
  { T_SIGNED,     "keyword",    R, "^signed"      },
  { T_SIZEOF,     "keyword",    R, "^sizeof"      },
  { T_STATIC,     "keyword",    R, "^static"      },
  { T_STRUCT,     "keyword",    R, "^struct"      },
  { T_SWITCH,     "keyword",    R, "^switch"      },
  { T_TYPEDEF,    "keyword",    R, "^typedef"     },
  { T_UNION,      "keyword",    R, "^union"       },
  { T_UNSIGNED,   "keyword",    R, "^unsigned"    },
  { T_VOID,       "keyword",    R, "^void"        },
  { T_VOLATILE,   "keyword",    R, "^volatile"    },
  { T_WHILE,      "keyword",    R, "^while"       },
  { T__BOOL,      "keyword",    R, "^_Bool"       },
  { T__COMPLEX,   "keyword",    R, "^_Complex"    },
  { T__IMAGINARY, "keyword",    R, "^_Imaginary"  },
  /* Punctuators (Ref #1 S6.4.6.1) */
  { T_OBRACE,     "",           R, "^\\["         },
  { T_CBRACE,     "",           R, "^\\]"         },
  { T_OPAREN,     "",           R, "^\\("         },
  { T_CPAREN,     "",           R, "^\\)"         },
  { T_OBRACK,     "",           R, "^\\{"         },
  { T_CBRACK,     "",           R, "^\\}"         },
  { T_DOT,        "",           R, "^\\."         },
  { T_RARROW,     "",           R, "^->"          },
  { T_PLUSPLUS,   "",           R, "^\\+\\+"      },
  { T_DASHDASH,   "",           R, "^--"          },
  { T_AMP,        "",           R, "^&"           },
  { T_STAR,       "",           R, "^\\*"         },
  { T_PLUS,       "",           R, "^\\+"         },
  { T_DASH,       "",           R, "^-"           },
  { T_SQUIG,      "",           R, "^~"           },
  { T_BANG,       "",           R, "^!"           },
  { T_SLASH,      "",           R, "^/"           },
  { T_PCT,        "",           R, "^%"           },
  { T_LTLT,       "",           R, "^<<"          },
  { T_GTGT,       "",           R, "^>>"          },
  { T_LT,         "",           R, "^<"           },
  { T_GT,         "",           R, "^>"           },
  { T_LTEQ,       "",           R, "^<="          },
  { T_GTEQ,       "",           R, "^>="          },
  { T_EQEQ,       "",           R, "^=="          },
  { T_BANGEQ,     "",           R, "^!="          },
  { T_CARET,      "",           R, "^\\^"         },
  { T_PIPE,       "",           R, "^\\|"         },
  { T_AMPAMP,     "",           R, "^&&"          },
  { T_PIPEPIPE,   "",           R, "^\\|\\|"      },
  { T_QMARK,      "",           R, "^\\?"         },
  { T_COLON,      "",           R, "^:"           },
  { T_SEMIC,      "",           R, "^;"           },
  { T_ELLIPSIS,   "",           R, "^\\.\\.\\."   },
  { T_EQ,         "",           R, "^="           },
  { T_STAREQ,     "",           R, "^\\*="        },
  { T_SLASHEQ,    "",           R, "^/="          },
  { T_PCTEQ,      "",           R, "^%="          },
  { T_PLUSEQ,     "",           R, "^\\+="        },
  { T_DASHEQ,     "",           R, "^-="          },
  { T_LTLTEQ,     "",           R, "^<<="         },
  { T_GTGTEQ,     "",           R, "^>>="         },
  { T_AMPEQ,      "",           R, "^\\&="        },
  { T_CARETEQ,    "",           R, "^\\^="        },
  { T_PIPEEQ,     "",           R, "^\\|="        },
  { T_COMMA,      "",           R, "^,"           },
  { T_HASH,       "",           R, "^#"           },
  { T_HASHISH,    "",           R, "^##"          },
  { T_LTCOLON,    "",           R, "^<:"          },
  { T_COLONGT,    "",           R, "^:>"          },
  { T_LTPCT,      "",           R, "^<%"          },
  { T_PCTGT,      "",           R, "^%>"          },
  { T_PCTCOLON,   "",           R, "^#%"          },
  { T_PCTCOLON2,  "",           R, "^#%#%"        }
};

/**
 * store list of each possible Lexeme, given a starting character.
 * we need to find the longest match for each token, and thus try all
 * possibilities. this lets us avoid trying everything every time.
 */
static struct {
  unsigned cnt;
  enum tok lexeme[17]; /* '#' for cpp, digraphs */
} Match[256]; /* one for each u8 */

static void match_add(const char c, enum tok t)
{
  int i = c;
  unsigned cnt = Match[i].cnt;
  assert(cnt < sizeof Match[0].lexeme / sizeof Match[0].lexeme[0]);
  Match[i].lexeme[cnt] = t;
  Match[i].cnt++;
}

/**
 * for each complex regular expression (T_SPACE through T_INDENT),
 * add the token to each character that may begin that token's match.
 */
static void match_build_regexes(void)
{
  char c;
  match_add(' ',  T_SPACE);
  match_add('\t', T_SPACE);
  match_add('\v', T_SPACE);
  match_add('\f', T_SPACE);
  match_add('\r', T_SPACE);
  match_add('\n', T_NEWLINE);
  match_add('/',  T_COMMENT);
  /* CPP */
  match_add('#',  T_CPP);
  match_add('#',  T_CPP_IFDEF);
  match_add('#',  T_CPP_IFNDEF);
  match_add('#',  T_CPP_IF);
  match_add('#',  T_CPP_ELIF);
  match_add('#',  T_CPP_ELSE);
  match_add('#',  T_CPP_ENDIF);
  match_add('#',  T_CPP_INCLUDE);
  match_add('#',  T_CPP_DEFINE);
  match_add('#',  T_CPP_UNDEF);
  match_add('#',  T_CPP_LINE);
  match_add('#',  T_CPP_PRAGMA);
  match_add('#',  T_CPP_IFDEF);
  match_add('\\', T_CPP_LINECONT);
  /* octal, decimal, hexadecimal integer constant */
  for (c = '0'; c <= '9'; c++)
    match_add(c,  T_CONST_INT);
  /* floating constant */
  match_add('.',  T_CONST_FLOAT);
  for (c = '0'; c <= '9'; c++)
    match_add(c,  T_CONST_FLOAT);
  match_add('L',  T_CONST_STR);
  match_add('"',  T_CONST_STR);
  match_add('L',  T_CONST_CHAR);
  match_add('\'', T_CONST_CHAR);
  /* identifiers */
  match_add('_',  T_IDENT);
  for (c = 'a'; c <= 'z'; c++)
    match_add(c,  T_IDENT);
  for (c = 'A'; c <= 'Z'; c++)
    match_add(c,  T_IDENT);
}

/**
 * for all patterns that constitute a simple, non-branching token,
 * programatically add the first char
 */
static void match_build_simple(void)
{
  enum tok t;
  for (t = T_AUTO; t < T_CNT; t++) {
    const char *c = Lexeme[t].pattern;
    c += ('^' == *c); /* skip regex "start of line" anchor, all patterns have this */
    c += ('\\' == *c); /* get to the first REAL char */
    c += ('\\' == *c);
    assert('\\' != *c);
    match_add(*c, t);
  }
}

/**
 * utility function
 */
static void rgxdie(const char *descr, const char *pattern, const regex_t *r, int errcode)
{
  char buf[64];
  regerror(errcode, r, buf, sizeof buf);
  fprintf(stderr, "%s: \"%s\" -> %s\n", descr, pattern, buf);
  exit(1);
}

static void match_compile(void)
{
  size_t i;
  for (i = 0; i < sizeof Lexeme / sizeof Lexeme[0]; i++) {
    int r;
    r = regcomp(&Lexeme[i].rgx, Lexeme[i].pattern, REG_EXTENDED);
    if (r != 0)
      rgxdie("regcomp", Lexeme[i].pattern, &Lexeme[i].rgx, r);
  }
}

/**
 * match the single, first longest token (as defined in Lemexe) found in 'buf'
 * of not more than 'buflen' chars
 * @return 0=no match, 1=match recorded in 't'
 */
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

void lexeme_show(const struct lexeme *t)
{
  if (T_NEWLINE == t->tok) {
    fputs("\\n\n", stdout);
  } else {
    printf("%s(%.*s)",
      Lexeme[t->tok].descr, (unsigned)t->len, t->str);
  }
}

int lexeme_cmp(const struct lexeme *a, const struct lexeme *b)
{
  return
    a->len == b->len &&
    a->str[0] == b->str[0] &&
    0 == memcmp(a->str, b->str, a->len);
}

void lexemelist_show(const struct lexeme *t)
{
  while (t) {
    lexeme_show(t);
    t = t->next;
  }
}

static void lexeme_init(struct lexeme *t)
{
  t->tok = T;
  t->len = 0U;
  t->str = NULL;
  t->loc.file = NULL;
  t->loc.line = 1UL;
  t->loc.off.total = 0UL;
  t->loc.off.line = 0UL;
}

static unsigned lexeme_newline_cnt(const struct lexeme *t)
{
  unsigned cnt = 0;
  switch (t->tok) {
  case T_CPP_LINECONT:
  case T_NEWLINE:
    /* always exactly one */
    cnt = 1;
    break;
  case T_COMMENT:
  case T_CPP:
    {
      size_t i = 0;
      while (i < t->len) {
        if ('\n' == t->str[i])
          cnt++;
        i++;
      }
    }
    break;
  default:
    break;
  }
  return cnt;
}

/**
 * token contains at least one newline.
 * we want to calculate the current line offset...
 * return the number of character at the end that are not newline.
 */
static unsigned lexeme_lastlinelen(const struct lexeme *t)
{
  unsigned cnt = 0;
  switch (t->tok) {
  /* NOTE: T_NEWLINE does not count towards line offset */
  case T_COMMENT:
  case T_CPP:
    {
      size_t i = t->len;
      while (i--)
        if ('\n' == t->str[i])
          break;
      cnt = t->len - i;
    }
    break;
  default:
    break;
  }
  return cnt;
}

/**
 * calculate the contents of curr->loc based on prev->loc
 */
static void lexeme_calc_loc(const struct lexeme *prev, struct lexeme *curr)
{
  unsigned nlcnt = lexeme_newline_cnt(prev);
  curr->loc = prev->loc; /* copy whole thing */
  curr->loc.line += nlcnt;
  curr->loc.off.total += prev->len;
  if (nlcnt) {
    /* prev token contained at least one newline;
     * calculate our current offset on current line */
    curr->loc.off.line = lexeme_lastlinelen(prev);
  } else {
    /* we're still on the same line as previous token */
    curr->loc.off.line += prev->len;
  }
  assert(curr->loc.line >= prev->loc.line);
}

/**
 * @return number of bytes of buf consumed; not more than buflen
 */
size_t lex(const char *buf, size_t buflen, struct lexeme **head)
{
  struct lexeme scratch;      /* always passed to match_one           */
  struct lexeme *tail = NULL; /* previous match, used to connect list */
  const char *curr = buf;
  size_t left = buflen;
  *head = NULL;
  lexeme_init(&scratch);
  /* initial match */
  if (match_one(curr, left, &scratch)) {
    struct lexeme *t = malloc(sizeof *t);
    if (t) {
      *t = scratch;
      *head = t;
      tail = t;
      left -= scratch.len;
      curr += scratch.len;
      /* subsequent matches */
      while (match_one(curr, left, &scratch)) {
        t = malloc(sizeof *t);
        if (t) {
          *t = scratch;
          lexeme_calc_loc(tail, t);
          tail->next = t;
          tail = t;
        }
        left -= scratch.len;
        curr += scratch.len;
      }
    }
    tail->next = NULL;
  }
  return buflen - left;
}

/**
 * utility function
 * read contents of FILE into a buffer
 */
static char * file2buf(FILE *f, size_t *len)
{
  size_t buflen = 4096;
  char *buf = malloc(buflen);
  *len = 0;
  if (buf) {
    size_t off = 0;
    ssize_t rd;
    do {
      ssize_t space;
      space = buflen - off;
      assert(space > 1);
      rd = read(fileno(f), buf+off, space - 1);
      if (rd > 0) {
        off += rd;
        if (off == buflen - 1) {
          char *tmp = realloc(buf, buflen*2);
          if (!tmp)
            break;
          buflen += buflen;
        }
      }
    } while (rd > 0);
    *len = off;
    buf[off] = '\0'; /* string-ize, ugh */
  }
  return buf;
}

size_t lex_file(FILE *f, struct lexeme **head)
{
  size_t buflen = 0;
  char *buf = file2buf(f, &buflen);
  size_t r = 0;
  if (buflen)
    r = lex(buf, buflen, head);
  return r;
}

int lex_init(void)
{
  match_build_simple();
  match_build_regexes();
  match_compile();
  return 1;
}

#ifdef TEST

int main(void)
{
  struct lexeme *l;
  l = NULL;
  lex_init();
  (void)lex_file(stdin, &l);
  lexemelist_show(l);
  return 0;
}

#endif

