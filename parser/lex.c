/* ex: set ts=2 noet: */

#define _POSIX_SOURCE

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
	{ T,		"",			R, "" },
	/* non-code */
	{ T_SPACE,			"whitespace",					R, "^[ \f\r\t\v]\\+" },
	{ T_NEWLINE,		"newline",	 					R, "^\n" },
	/* TODO: multi-line weird preprocessor comment crap; it's going to be a bitch getting it to work in this crappy syntax*/
	{ T_COMMENT,		"comment",	 					R, "^\\(/\\*\\([^\\0]*\\)\\*/\\|//[^\\0\n]*\n\\|//[^\\0\n]*\\)" }, //|//[^\\n]\\+\\)" }, //|\\(\\(//\\|/\\\n/\\)[^\n]*\\(\n\\|\\\n[^\n]*\n\\)\\)\\+
	{ T_CPP,  			"preprocessor",				R, "#\\(include\\|define\\|\\)[^\\n]*\n" },
	/* constant values */
	{ T_CONST_FLOAT,"float",	 						R, "^[0-9]\\.\\([[:digit:]]\\+\\([eE][+-]\\?[0-9]\\+\\)\\?\\)\\?" },
	{ T_CONST_INT,	"integer_constant",		R, "^\\(0[xX][[:xdigit:]]\\+\\|0[0-7]*\\|[123456789][0123456789]*\\)[uU]\\?[lL]\\?[lL]\\?" },
	{ T_CONST_STR,	"string_literal",			R, "^L\\?\"\\([^\"]\\+\\|\\\"\\)*\"" },
	{ T_CONST_CHAR,	"character_constant",	R, "^L\\?'\\([^']*\\|\\\\'\\)*'" },
	{ T_IDENT,			"identifier",					R, "^[_a-zA-Z]\\([_a-zA-Z0-9]\\+\\|\\\\u[[:xdigit:]]\\{4\\}\\|\\\\U[[:xdigit:]]\\{8\\}\\)*" },
	/* keywords */
	{ T_AUTO,				"keyword",		R, "^auto"				},
	{ T_BREAK,			"keyword",		R, "^break"		 		},
	{ T_CASE,				"keyword",		R, "^case"				},
	{ T_CHAR,				"keyword",		R, "^char"				},
	{ T_CONST,			"keyword",		R, "^const"		 		},
	{ T_CONTINUE,		"keyword",		R, "^continue"		},
	{ T_DEFAULT,		"keyword",		R, "^default"	 		},
	{ T_DO,					"keyword",		R, "^do"					},
	{ T_DOUBLE,			"keyword",		R, "^double"			},
	{ T_ELSE,				"keyword",		R, "^else"				},
	{ T_ENUM,				"keyword",		R, "^enum"				},
	{ T_EXTERN,			"keyword",		R, "^extern"			},
	{ T_FLOAT,			"keyword",		R, "^float"		 		},
	{ T_FOR,				"keyword",		R, "^for"	 				},
	{ T_GOTO,				"keyword",		R, "^goto"				},
	{ T_IF,					"keyword",		R, "^if"					},
	{ T_INLINE,			"keyword",		R, "^inline"			},
	{ T_INT,				"keyword",		R, "^int"	 				},
	{ T_LONG,				"keyword",		R, "^long"				},
	{ T_REGISTER,		"keyword",		R, "^register"		},
	{ T_RESTRICT,		"keyword",		R, "^restrict"		},
	{ T_RETURN,			"keyword",		R, "^return"			},
	{ T_SHORT,			"keyword",		R, "^short"		 		},
	{ T_SIGNED,			"keyword",		R, "^signed"			},
	{ T_SIZEOF,			"keyword",		R, "^sizeof"			},
	{ T_STATIC,			"keyword",		R, "^static"			},
	{ T_STRUCT,			"keyword",		R, "^struct"			},
	{ T_SWITCH,			"keyword",		R, "^switch"			},
	{ T_TYPEDEF,		"keyword",		R, "^typedef"	 		},
	{ T_UNION,			"keyword",		R, "^union"		 		},
	{ T_UNSIGNED,		"keyword",		R, "^unsigned"		},
	{ T_VOID,				"keyword",		R, "^void"				},
	{ T_VOLATILE,		"keyword",		R, "^volatile"		},
	{ T_WHILE,			"keyword",		R, "^while"		 		},
	{ T__BOOL,			"keyword",		R, "^_Bool"		 		},
	{ T__COMPLEX,		"keyword",		R, "^_Complex"		},
	{ T__IMAGINARY,	"keyword",		R, "^_Imaginary"	},
	/* punctuators */
	/* last by length, descending.
	 * knowing that Match[] elements are in this order similifies
	 * our implementation of "find the longest match" */
	{ T_OBRACE,			"",						R, "^\\["	 				},
	{ T_CBRACE,			"",						R, "^\\]"	 				},
	{ T_OPAREN,			"",						R, "^("		 				},
	{ T_CPAREN,			"",						R, "^)"		 				},
	{ T_OBRACK,			"",						R, "^{"		 				},
	{ T_CBRACK,			"",						R, "^}"		 				},
	{ T_DOT,				"",						R, "^\\."	 				},
	{ T_RARROW,			"",						R, "^->"					},
	{ T_PLUSPLUS,		"",						R, "^++"					},
	{ T_DASHDASH,		"",						R, "^--"					},
	{ T_AMP,				"",						R, "^&"		 				},
	{ T_STAR,				"",						R, "^*"		 				},
	{ T_PLUS,				"",						R, "^+"		 				},
	{ T_DASH,				"",						R, "^-"		 				},
	{ T_SQUIG,			"",						R, "^~"		 				},
	{ T_BANG,				"",						R, "^!"		 				},
	{ T_SLASH,			"",						R, "^/"		 				},
	{ T_PCT,				"",						R, "^%"		 				},
	{ T_LTLT,				"",						R, "^<<"					},
	{ T_GTGT,				"",						R, "^>>"					},
	{ T_LT,					"",						R, "^<"		 				},
	{ T_GT,					"",						R, "^>"		 				},
	{ T_LTEQ,				"",						R, "^<="					},
	{ T_GTEQ,				"",						R, "^>="					},
	{ T_EQEQ,				"",						R, "^=="					},
	{ T_BANGEQ,			"",						R, "^!="					},
	{ T_CARET,			"",						R, "^\\\\^"		 		},
	{ T_PIPE,				"",						R, "^\\|"	 				},
	{ T_AMPAMP,			"",						R, "^&&"					},
	{ T_PIPEPIPE,		"",						R, "^||"					},
	{ T_QMARK,			"",						R, "^\\?"	 				},
	{ T_COLON,			"",						R, "^:"		 				},
	{ T_SEMIC,			"",						R, "^;"		 				},
	{ T_ELLIPSIS,		"",						R, "^\\.\\.\\."	 	},
	{ T_EQ,					"",						R, "^="		 				},
	{ T_STAREQ,			"",						R, "^*="					},
	{ T_SLASHEQ,		"",						R, "^/="					},
	{ T_PCTEQ,			"",						R, "^%="					},
	{ T_PLUSEQ,			"",						R, "^+="					},
	{ T_DASHEQ,			"",						R, "^-="					},
	{ T_LTLTEQ,			"",						R, "^<<="	 				},
	{ T_GTGTEQ,			"",						R, "^>>="	 				},
	{ T_AMPEQ,			"",						R, "^&="					},
	{ T_CARETEQ,		"",						R, "^\\\\^="			},
	{ T_PIPEEQ,			"",						R, "^\\|="				},
	{ T_COMMA,			"",						R, "^,"		 				},
	{ T_HASH,				"",						R, "^#"		 				},
	{ T_HASHISH,		"",						R, "^##"					},
	{ T_LTCOLON,		"",						R, "^<:"					},
	{ T_COLONGT,		"",						R, "^:>"					},
	{ T_LTPCT,			"",						R, "^<%"					},
	{ T_PCTGT,			"",						R, "^%>"					},
	{ T_PCTCOLON,		"",						R, "^#%"					},
	{ T_PCTCOLON2,	"",						R, "^#%#%"				}
};

/**
 * store list of each possible Lexeme, given a starting character.
 * we need to find the longest match for each token, and thus try all
 * possibilities. this lets us avoid trying everything every time.
 */
static struct {
	unsigned cnt;
	enum tok lexeme[7];
} Match[256];

static void match_add(const char c, enum tok t)
{
	int i = c;
	unsigned cnt = Match[i].cnt;
	assert(cnt < sizeof Match[0].lexeme / sizeof Match[0].lexeme[0]);
	Match[i].lexeme[cnt] = t;
	Match[i].cnt++;
}

static void match_build_regexes(void)
{
	char c;
	
	match_add(' ',	T_SPACE);
	match_add('\t', T_SPACE);
	match_add('\v', T_SPACE);
	match_add('\f', T_SPACE);
	match_add('\r', T_SPACE);
	
	match_add('\n', T_NEWLINE);
	
	match_add('/',	T_COMMENT);
	
	match_add('#',	T_CPP);
	
	for (c = '0'; c < '9'; c++)
		match_add(c,	T_CONST_FLOAT);
	
	for (c = '0'; c < '9'; c++)
		match_add(c,	T_CONST_INT);
	
	match_add('L',	T_CONST_STR);
	match_add('"',	T_CONST_STR);
	
	match_add('L',	T_CONST_CHAR);
	match_add('\'', T_CONST_CHAR);
	
	match_add('_',	T_IDENT);
	for (c = 'a'; c < 'z'; c++)
		match_add(c,	T_IDENT);
	for (c = 'A'; c < 'Z'; c++)
		match_add(c,	T_IDENT);
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
		c += ('^' == *c);
		c += ('\\' == *c);
		c += ('\\' == *c);
		assert('\\' != *c);
		match_add(*c, t);
	}
}

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
	enum tok		tok;
	size_t	len;
	const char	 *str;
	struct token *next;
};

/**
 * match the single, first longest token (as defined in Lemexe) found in 'buf'
 * of not more than 'buflen' chars
 * @return	1 - match recorded in 't'
 *		0 - no match
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
				if (0 != m[0].rm_so)
				{
					printf("should be entire match, but m[0].rm_so=%d (m[0].rm_eo=%d)\n",
						m[0].rm_so, m[0].rm_eo);
					exit(1);
				}
				assert(len > 0 && "should match something");
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

#if 0
static void token_dump(const struct token *t)
{
	printf("token tok=%d len=%u str=\"%.*s\" next=%p\n",
		(int)t->tok, (unsigned)t->len, (unsigned)t->len, t->str, (void *)t->next);
}
#endif

#if 0
static void tokenlist_dump(const struct token *t)
{
	while (t) {
		token_dump(t);
		t = t->next;
	}
}
#endif

static void token_show(const struct token *t)
{
	if (Lexeme[t->tok].descr[0]) {
		printf("%s(%.*s)\n",
			Lexeme[t->tok].descr, (unsigned)t->len, t->str);
	} else {
		printf("%.*s\n",
			(unsigned)t->len, t->str);
	}
}

static void tokenlist_show(const struct token *t)
{
	while (t) {
		token_show(t);
		t = t->next;
	}
}

static size_t match_all(const char *buf, size_t buflen, struct token **head)
{
	struct token scratch; /* always passed to match_one */
	struct token *tail = NULL; /* last token matched, used to connect subsequent matches */
	const char *curr = buf;
	size_t left = buflen;
	
	*head = NULL;
	while (left && match_one(curr, left, &scratch)) {
		struct token *t;
		t = malloc(sizeof *t);
		if (t) {
			*t = scratch;
			if (!*head)
				*head = t;
			if (tail)
				tail->next = t;
			tail = t;
		}
		assert(scratch.len <= left);
		left -= scratch.len;
		curr += scratch.len;
	}
	return buflen - left;
}

#if 0
static void test_match_one(void)
{
	struct token t;
	{
		const char str[] = "auto ";
		assert(match_one(str, sizeof(str) - 1, &t));
		assert(T_AUTO	 == Lexeme[t.tok].id);
		assert(4	== t.len);
		assert(str		== t.str);
	}
	{ /* ensure longest match occurs */
		const char str[] = "<<==>>";
		assert(match_one(str, sizeof(str) - 1, &t));
		assert(T_LTLTEQ == Lexeme[t.tok].id);
		assert(3	== t.len);
		assert(str		== t.str);
	}
}
#endif

/**
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

