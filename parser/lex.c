/* ex: set ts=2 et: */
/*
 * lexer for C99
 */

#define _POSIX_SOURCE /* get stdio.h/fileno() */

#include <assert.h>
#include <stdio.h>
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

static struct {
  enum tok id;
  const char *descr;
  regex_t rgx;
  const char *pattern;
} Lexeme[T_CNT] = {
  { T,            "",           R, ""             }, /* nothing */
  { T_SPACE,      "ws",         R, "^[ \f\r\t\v]\\+"
                                                  },
  { T_NEWLINE,    "nl",         R, "^\n"          },
  { T_COMMENT,    "comment",    R,
  /* TODO: multi-line weird preprocessor comment crap;
   * it's going to be a bitch getting it to work in
   * this crappy syntax */
  /* //|//[^\\n]\\+\\)" }, //|\\(\\(//\\|/\\\n/\\)[^\n]*\\(\n\\|\\\n[^\n]*\n\\)\\)\\+ */
    "^\\("
      /* C-style comment, like this */
      "/\\*" 
        "\\("
          "[^*\\]\\+" /* anything but \ and * */
          "\\|"       /* or */
          "\\*[^/]"   /* an asterisk followed by something other than / */
          "\\|"       /* or */
          "\\\\."     /* escaped something */
          "\\)*"
      "\\*/"
      "\\|" /* or */
      /* C++ style "//" */
      "//[^\n]*\n\\|//[^\n]*" 
    "\\)"
                                                  }, 
  { T_CPP,        "cpp",        R,
    "#[ \f\r\t\v]*\\(include\\|define\\|\\)[^\n]*\n"
                                                  },
  /* constant values */
  { T_CONST_FLOAT,"float_lit",  R,
    "^\\("
      /* decimal float */
      "\\([0-9]\\(\\.[0-9]*\\)\\?\\|\\.[0-9]\\+\\)\\([eE][+-]\\?[0-9]\\+\\)\\?"
      "\\|"
      /* hexadecimal float */
      "0[xX][[:xdigit:]]\\+\\(\\.[[:xdigit:]]\\+\\)\\?[pP][+-]\\?[0-9]\\+"
    "\\)"
    /* suffix */
    "\\([fF]\\?[lL]\\?\\|[lL][fF]\\)\\?"
                                                  },
  { T_CONST_INT,  "int_lit",    R,
    "^\\(0[xX][[:xdigit:]]\\+\\|0[0-7]*\\|[1-9][0-9]*\\)[uU]\\?[lL]\\?[lL]\\?"
                                                  },
  { T_CONST_STR,  "str_lit",    R,
    "^L\\?\"\\([^\"\n]\\+\\|\\\\\"\\+\\)*\""
                                                  },
  { T_CONST_CHAR,  "char_lit",  R,
    "^"
      "L\\?" /* optional wchar_t */
      "'"
        "\\("
          "\\\\'"   /* escaped single char */
          "\\|"     /* or */
          "\\\\."   /* escaped anything */
          "\\|"     /* or */
          "[^\\']"  /* any single char other than ' or \ */
        "\\)*"
      "'"
                                                  },
  { T_IDENT,      "ident",      R,
    "^[_a-zA-Z]"                      /* must start with non-digit */
    "\\([_a-zA-Z0-9]\\+"              /* may continue with alphanumeric... */
    "\\|\\\\u[[:xdigit:]]\\{4\\}"     /* or "small" universal names... */
    "\\|\\\\U[[:xdigit:]]\\{8\\}\\)*" /* or "big" ones. */
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
  { T_OPAREN,     "",           R, "^("           },
  { T_CPAREN,     "",           R, "^)"           },
  { T_OBRACK,     "",           R, "^{"           },
  { T_CBRACK,     "",           R, "^}"           },
  { T_DOT,        "",           R, "^\\."         },
  { T_RARROW,     "",           R, "^->"          },
  { T_PLUSPLUS,   "",           R, "^++"          },
  { T_DASHDASH,   "",           R, "^--"          },
  { T_AMP,        "",           R, "^&"           },
  { T_STAR,       "",           R, "^*"           },
  { T_PLUS,       "",           R, "^+"           },
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
  { T_PIPE,       "",           R, "^|"           },
  { T_AMPAMP,     "",           R, "^&&"          },
  { T_PIPEPIPE,   "",           R, "^||"          },
  { T_QMARK,      "",           R, "^?"           },
  { T_COLON,      "",           R, "^:"           },
  { T_SEMIC,      "",           R, "^;"           },
  { T_ELLIPSIS,   "",           R, "^\\.\\.\\."   },
  { T_EQ,         "",           R, "^="           },
  { T_STAREQ,     "",           R, "^*="          },
  { T_SLASHEQ,    "",           R, "^/="          },
  { T_PCTEQ,      "",           R, "^%="          },
  { T_PLUSEQ,     "",           R, "^+="          },
  { T_DASHEQ,     "",           R, "^-="          },
  { T_LTLTEQ,     "",           R, "^<<="         },
  { T_GTGTEQ,     "",           R, "^>>="         },
  { T_AMPEQ,      "",           R, "^&="          },
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
  enum tok lexeme[7]; /* 's' has 7 possible matches:
                       * short, sizeof, static, signed, struct, switch, $ident */
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
  
  match_add('#',  T_CPP);
  
  for (c = '0'; c <= '9'; c++) {
    match_add(c,  T_CONST_INT);
  }
  
  for (c = '0'; c <= '9'; c++) {
    match_add(c,  T_CONST_FLOAT);
  }
  match_add('.',  T_CONST_FLOAT);
  
  match_add('L',  T_CONST_STR);
  match_add('"',  T_CONST_STR);
  
  match_add('L',  T_CONST_CHAR);
  match_add('\'', T_CONST_CHAR);
  
  match_add('_',  T_IDENT);
  for (c = 'a'; c <= 'z'; c++) {
    match_add(c,  T_IDENT);
  }
  for (c = 'A'; c <= 'Z'; c++) {
    match_add(c,  T_IDENT);
  }
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
    r = regcomp(&Lexeme[i].rgx, Lexeme[i].pattern, 0);
    if (r != 0)
      rgxdie("regcomp", Lexeme[i].pattern, &Lexeme[i].rgx, r);
  }
}

/**
 * add a reference
 */
static void match_build(void)
{
  match_build_simple();
  match_build_regexes();
  match_compile();
}

struct token {
  enum tok      tok;
  size_t        len;
  const char   *str;
  struct token *next;
};

/**
 * match the single, first longest token (as defined in Lemexe) found in 'buf'
 * of not more than 'buflen' chars
 * @return  1 - match recorded in 't'
 *    0 - no match
 */
static int match_one(const char *buf, size_t buflen, struct token *t)
{
  t->tok = T;
  if (buflen > 0) {
    unsigned i = 0;
    unsigned longl;
    int c = *buf;
    regoff_t longest = 0;
    //printf("match_one buf=\"%.*s\" c='%c'\n", (unsigned)buflen, buf, *buf);
    while (i < Match[c].cnt)
    {
      regmatch_t m[4];
      int l, r;
      l = Match[c].lexeme[i];
      //printf("buf=\"%.*s\" try=\"%s\"...\n", (unsigned)buflen, buf, Lexeme[l].pattern);
      r = regexec(&Lexeme[l].rgx, buf, sizeof m / sizeof m[0], m, 0);
      if (r != REG_NOMATCH) {
        /* first match is always the correct one */
        int len = m[0].rm_eo;
        //printf("match \"%.*s\"\n", len, buf+m[0].rm_so);
        if (0 != m[0].rm_so || 0 == len)
        {
          fprintf(stderr, "should start at beginning and match (>0) chars but m[0].rm_so=%d (m[0].rm_eo=%d)\n",
            m[0].rm_so, m[0].rm_eo);
          exit(1);
        }
        assert((size_t)len <= buflen && "match should be shorter than buf's contents");
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

static void token_show(const struct token *t)
{
  switch (t->tok) {
  case T_NEWLINE:
    fputs("\\n\n", stdout);
    break;
  default:
    if (Lexeme[t->tok].descr[0]) {
      printf("%s(%.*s)",
        Lexeme[t->tok].descr, (unsigned)t->len, t->str);
    } else {
      printf("(%.*s)",
        (unsigned)t->len, t->str);
    }
    break;
  }
}

static void tokenlist_show(const struct token *t)
{
  while (t) {
    token_show(t);
    t = t->next;
  }
}

/**
 * @return number of bytes of buf consumed; not more than buflen
 */
static size_t match_all(const char *buf, size_t buflen, struct token **head)
{
  struct token scratch; /* always passed to match_one */
  struct token *tail = NULL; /* last token matched, used to connect subsequent matches */
  const char *curr = buf;
  size_t left = buflen;
  *head = NULL;
  if (match_one(curr, left, &scratch)) {
    /* initial match */
    struct token *t = malloc(sizeof *t);
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

static void test_match_stdin(void)
{
  size_t buflen = 0;
  char *buf;
  buf = file2buf(stdin, &buflen);
  if (buflen) {
    struct token *t = NULL;
    size_t match;
#if 0
    printf("buflen=%lu\n", (unsigned long)buflen);
#endif
    match = match_all(buf, buflen, &t);
    tokenlist_show(t);
  } else {
    printf("couldn't read stdin!\n");
  }
}

int main(void)
{
  match_build();
  test_match_stdin();
  return 0;
}

