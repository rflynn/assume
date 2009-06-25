/* ex: set ts=2 et: */

#ifndef LEX_H
#define LEX_H

#include <stddef.h> /* size_t */

enum tok {
  T, /* nothing; exists for debugging lex.Match[] */
  /* non-code */
  T_SPACE,
  T_NEWLINE,
  T_COMMENT,
  /* CPP */
  T_CPP,
  T_CPP_IFDEF,
  T_CPP_IFNDEF,
  T_CPP_IF,
  T_CPP_ELIF,
  T_CPP_ELSE,
  T_CPP_ENDIF,
  T_CPP_INCLUDE,
  T_CPP_DEFINE,
  T_CPP_UNDEF,
  T_CPP_LINE,
  T_CPP_ERROR,
  T_CPP_PRAGMA,
  T_CPP_LINECONT,
  /* constant values */
  T_CONST_FLOAT,
  T_CONST_INT,
  T_CONST_STR,
  T_CONST_CHAR,
  T_IDENT,
  /* keywords */
  T_AUTO,
  T_BREAK,
  T_CASE,
  T_CHAR,
  T_CONST,
  T_CONTINUE,
  T_DEFAULT,
  T_DO,
  T_DOUBLE,
  T_ELSE,
  T_ENUM,
  T_EXTERN,
  T_FLOAT,
  T_FOR,
  T_GOTO,
  T_IF,
  T_INLINE,
  T_INT,
  T_LONG,
  T_REGISTER,
  T_RESTRICT,
  T_RETURN,
  T_SHORT,
  T_SIGNED,
  T_SIZEOF,
  T_STATIC,
  T_STRUCT,
  T_SWITCH,
  T_TYPEDEF,
  T_UNION,
  T_UNSIGNED,
  T_VOID,
  T_VOLATILE,
  T_WHILE,
  T__BOOL,
  T__COMPLEX,
  T__IMAGINARY,
  /* punctuators */
  T_OBRACE,
  T_CBRACE,
  T_OPAREN,
  T_CPAREN,
  T_OBRACK,
  T_CBRACK,
  T_DOT,
  T_RARROW,
  T_PLUSPLUS,
  T_DASHDASH,
  T_AMP,
  T_STAR,
  T_PLUS,
  T_DASH,
  T_SQUIG,
  T_BANG,
  T_SLASH,
  T_PCT,
  T_LTLT,
  T_GTGT,
  T_LT,
  T_GT,
  T_LTEQ,
  T_GTEQ,
  T_EQEQ,
  T_BANGEQ,
  T_CARET,
  T_PIPE,
  T_AMPAMP,
  T_PIPEPIPE,
  T_QMARK,
  T_COLON,
  T_SEMIC,
  T_ELLIPSIS,
  T_EQ,
  T_STAREQ,
  T_SLASHEQ,
  T_PCTEQ,
  T_PLUSEQ,
  T_DASHEQ,
  T_LTLTEQ,
  T_GTGTEQ,
  T_AMPEQ,
  T_CARETEQ,
  T_PIPEEQ,
  T_COMMA,
  T_HASH,
  T_HASHISH,
  T_LTCOLON,
  T_COLONGT,
  T_LTPCT,
  T_PCTGT,
  T_PCTCOLON,
  T_PCTCOLON2,
  /* last, special */
  T_CNT
};

/**
 * the atomic unit of syntax
 */
struct lexeme {
  enum tok      tok;
  size_t        len;
  const char   *str;
  struct {
    const char *file;
    unsigned long line;
    struct {
      unsigned long total;
      unsigned line;
    } off;
  } loc;
  struct lexeme *next;
};

int    lex_init(void);
size_t lex(const char *buf, size_t buflen, struct lexeme **head);
size_t lex_file(FILE *f, struct lexeme **head);
void   lexemelist_show(const struct lexeme *);
void   lexeme_show(const struct lexeme *);
int lexeme_cmp(const struct lexeme *, const struct lexeme *);

#endif

