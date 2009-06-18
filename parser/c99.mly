/* C99 parser */

%{
open Printf
%}

%token NEWLINE
%token <string> CPP
%token <string> WHITESPACE
%token <string> COMMENT
%token <string> HEADER_NAME
%token <string> PP_NUMBER
%token <string> INTEGER_CONSTANT_DEC
%token <string> FLOATING_CONSTANT
%token <string> CHARACTER_CONSTANT
%token <string> STRING_LITERAL
%token <string> IDENTIFIER
%token AUTO
%token BREAK
%token CASE
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOAT
%token FOR
%token GOTO
%token IF
%token INLINE
%token INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE
%token BOOL
%token COMPLEX
%token IMAGINARY
%token SEMIC

%start translation_unit
%type <unit> translation_unit

%% /* Grammar rules and actions follow */

translation_unit:
  external_declaration {}
  | translation_unit external_declaration {}
  ;

external_declaration:
  function_definition {}
  | declaration {}
  ;

function_definition:
  declaration_specifiers declarator compound_statement {}
  | declaration_specifiers declarator declaration_list compound_statement {}
  ;

declaration_list:
  declaration {}
  | declaration_list declaration {}
  ;

primary_expr:
  IDENTIFIER {}
  | constant {}
  | string_literal {}
  | "(" expr ")" {}
  ;

constant:
  integer_constant {}
  | floating_constant {}
  | enumeration_constant {}
  | character_constant {}
  ;

string_literal:
  STRING_LITERAL { printf "string_literal(%s)\n" $1; }
  ;

integer_constant:
  INTEGER_CONSTANT_DEC { printf "integer_constant(%s)\n" $1; }
  ;

floating_constant:
  FLOATING_CONSTANT { printf "floating_constant(%s)\n" $1; }
  ;

enumeration_constant:
  "FIXME:enumeration_constant" IDENTIFIER { printf "enumeration_constant(%s)\n", $2; }
  ;

character_constant:
  CHARACTER_CONSTANT { printf "character_constant(%s)\n", $1; }
  ;

postfix_expr:
  primary_expr {}
  | postfix_expr "[" expr "]" {}
  | postfix_expr "(" argument_expr_list ")" {}
  | postfix_expr "(" ")" {}
  | postfix_expr "." IDENTIFIER {}
  | postfix_expr "->" IDENTIFIER {}
  | postfix_expr "++" {}
  | postfix_expr "--" {}
  | "(" type_name ")" "{" initializer_list "}" {}
  | "(" type_name ")" "{" initializer_list "," "}" {}
  ;

argument_expr_list:
  assignment_expr {}
  | argument_expr_list "," assignment_expr {}
  ;

unary_expr:
  postfix_expr {}
  | "++" unary_expr {}
  | "--" unary_expr {}
  | unary_operator cast_expr {}
  | SIZEOF unary_expr {}
  | SIZEOF "(" type_name ")" {}
  ;

unary_operator:
  "&" {}
  | "*"  {}
  | "+"  {}
  | "-"  {}
  | "~"  {}
  | "!" {}
  ;

cast_expr:
  unary_expr {}
  | "(" type_name ")" cast_expr {}
  ;

mult_expr:
  cast_expr {}
  | mult_expr "*" cast_expr {}
  | mult_expr "/" cast_expr {}
  | mult_expr "%" cast_expr {}
  ;

add_expr:
  mult_expr {}
  | add_expr "+" mult_expr {}
  | add_expr "-" mult_expr {}
  ;

shift_expr:
  add_expr {}
  | shift_expr "<<" add_expr {}
  | shift_expr ">>" add_expr {}
  ;

relational_expr:
  shift_expr {}
  | relational_expr "<" shift_expr {}
  | relational_expr ">" shift_expr {}
  | relational_expr "<=" shift_expr {}
  | relational_expr ">=" shift_expr {}
  ;

equality_expr:
  relational_expr {}
  | equality_expr "==" relational_expr {}
  | equality_expr "!=" relational_expr {}
  ;

and_expr:
  equality_expr {}
  | and_expr "&" equality_expr {}
  ;

exclusive_or_expr:
  and_expr {}
  | exclusive_or_expr "^" and_expr {}
  ;

inclusive_or_expr:
  exclusive_or_expr {}
  | inclusive_or_expr "|" exclusive_or_expr {}
  ;

logical_and_expr:
  inclusive_or_expr {}
  | logical_and_expr "&&" inclusive_or_expr {}
  ;

logical_or_expr:
  logical_and_expr {}
  | logical_or_expr "||" logical_and_expr {}
  ;

conditional_expr:
  logical_or_expr {}
  | logical_or_expr "?" expr ":" conditional_expr {}
  ;

assignment_expr:
  conditional_expr {}
  | unary_expr assignment_operator assignment_expr {}
  ;

assignment_operator:
  "=" {}
  | "*=" {}
  | "/=" {}
  | "%=" {}
  | "+=" {}
  | "-=" {}
  | "&=" {}
  | "^=" {}
  | "|=" {}
  | "<<=" {}
  | ">>=" {}
  ;

expr:
  assignment_expr {}
  | expr "," assignment_expr {}
  ;

constant_expr:
  conditional_expr {}
  ;

declaration:
  declaration_specifiers init_declarator_list {}
  | declaration_specifiers {}
  ;

declaration_specifiers:
  declaration_specifier {}
  | declaration_specifiers declaration_specifier {}
  ;

declaration_specifier:
  storage_class_specifier {}
  | type_specifier {}
  | type_qualifier {}
  | function_specifier {}
  ;

init_declarator_list:
  init_declarator {}
  | init_declarator_list "," init_declarator {}
  ;

init_declarator:
  declarator "=" initializer_ {}
  | declarator {}
  ;

storage_class_specifier:
  TYPEDEF     {}
  | EXTERN    {}
  | STATIC    {}
  | AUTO      {}
  | REGISTER  {}
  ;

type_specifier:
  VOID        {}
  | CHAR      {}
  | SHORT     {}
  | INT       {}
  | LONG      {}
  | FLOAT     {}
  | DOUBLE    {}
  | SIGNED    {}
  | UNSIGNED  {}
  | BOOL      {}
  | COMPLEX   {}
  | IMAGINARY {}
  | struct_or_union_specifier {}
  | enum_specifier {}
  | typedef_name {}
  ;

struct_or_union_specifier:
  struct_or_union IDENTIFIER "{" struct_declaration_list "}" {}
  | struct_or_union "{" struct_declaration_list "}" {}
  | struct_or_union IDENTIFIER {}
  ;

struct_or_union:
  STRUCT {}
  | UNION {}
  ;

struct_declaration_list:
  struct_declaration {}
  | struct_declaration_list struct_declaration {}
  ;

struct_declaration:
  specifier_qualifier_list struct_declarator_list ";" {}
  ;

specifier_qualifier_list:
  type_specifier specifier_qualifier_list {}
  | type_specifier {}
  | type_qualifier specifier_qualifier_list {}
  | type_qualifier {}
  ;

struct_declarator_list:
  struct_declarator {}
  | struct_declarator_list "," struct_declarator {}
  ;

struct_declarator:
  declarator {}
  | declarator ":" constant_expr {}
  | ":" constant_expr {}
  ;

enum_specifier:
    ENUM IDENTIFIER "{" enumerator_list "}" {}
  | ENUM            "{" enumerator_list "}" {}
  | ENUM IDENTIFIER "{" enumerator_list "," "}" {}
  | ENUM            "{" enumerator_list "," "}" {}
  | ENUM IDENTIFIER {}
  ;

enumerator_list:
  enumerator {}
  | enumerator_list "," enumerator {}
  ;

enumerator:
  enumeration_constant {}
  | enumeration_constant "=" constant_expr {}
  ;

type_qualifier:
  CONST {}
  | RESTRICT {}
  | VOLATILE {}
  ;

function_specifier:
  INLINE {}
  ;

declarator:
  pointer direct_declarator {}
  | direct_declarator {}
  ;

direct_declarator:
  IDENTIFIER {}
  | "(" declarator ")" {}
  | direct_declarator "[" type_qualifier_list assignment_expr "]" {}
  | direct_declarator "[" type_qualifier_list "]" {}
  | direct_declarator "[" assignment_expr "]" {}
  | direct_declarator "[" "]" {}
  | direct_declarator "[" STATIC type_qualifier_list assignment_expr "]" {}
  | direct_declarator "[" STATIC assignment_expr "]" {}
  | direct_declarator "[" type_qualifier_list STATIC assignment_expr "]" {}
  | direct_declarator "[" type_qualifier_list "*" "]" {}
  | direct_declarator "[" "*" "]" {}
  | direct_declarator "(" parameter_type_list ")" {}
  | direct_declarator "(" identifier_list ")" {}
  | direct_declarator "(" ")" {}
  ;

pointer:
  "*" type_qualifier_list {}
  | "*" {}
  | "*" type_qualifier_list pointer {}
  | "*" pointer {}
  ;

type_qualifier_list:
  type_qualifier {}
  | type_qualifier_list type_qualifier {}
  ;

parameter_type_list:
  parameter_list {}
  | parameter_list "," "..." {}
  ;

parameter_list:
  parameter_declaration {}
  | parameter_list "," parameter_declaration {}
  ;

parameter_declaration:
  declaration_specifiers declarator {}
  | declaration_specifiers abstract_declarator {}
  | declaration_specifiers {}
  ;

identifier_list:
  IDENTIFIER {}
  | identifier_list "," IDENTIFIER {}
  ;

type_name:
  specifier_qualifier_list abstract_declarator {}
  | specifier_qualifier_list {}
  ;

abstract_declarator:
  pointer {}
  | pointer direct_abstract_declarator {}
  | direct_abstract_declarator {}
  ;

direct_abstract_declarator:
  "(" abstract_declarator ")" {}
  | direct_abstract_declarator "[" assignment_expr "]" {}
  | "[" assignment_expr "]" {}
  | direct_abstract_declarator "[" "]" {}
  | "[" "]" {}
  | direct_abstract_declarator "[" "*" "]" {}
  | "[" "*" "]" {}
  | direct_abstract_declarator "(" parameter_type_list ")" {}
  | direct_abstract_declarator "(" ")" {}
  | "(" ")" {}
  ;

/* FIXME: need to keep track of struct/enum/union/typedef names */
  typedef_name:
  "FIXME:typedef_name" IDENTIFIER {}
  ;

initializer_:
  assignment_expr {}
  | "{" initializer_list "}" {}
  | "{" initializer_list "," "}" {}
  ;

initializer_list:
  designation initializer_ {}
  | initializer_ {}
  | initializer_list "," designation initializer_ {}
  | initializer_list "," initializer_ {}
  ;

designation:
  designator_list "=" {}
  ;

designator_list:
  designator {}
  | designator_list designator {}
  ;

designator:
  "[" constant_expr "]" {}
  | "." IDENTIFIER {}
  ;

statement:
  labeled_statement {}
  | compound_statement {}
  | expr_statement {}
  | selection_statement {}
  | iteration_statement {}
  | jump_statement {}
  ;

labeled_statement:
  IDENTIFIER ":" statement {}
  | CASE constant_expr ":" statement {}
  | DEFAULT ":" statement {}
  ;

compound_statement:
  "{" block_item_list "}" {}
  | "{" "}" {}
  ;

block_item_list:
  block_item {}
  | block_item_list block_item {}
  ;

block_item:
  declaration {}
  | statement {}
  ;

expr_statement:
  expr ";" {}
  | ";" {}
  ;

selection_statement:
  IF "(" expr ")" statement {}
  | IF "(" expr ")" statement ELSE statement {}
  | SWITCH "(" expr ")" statement {}
  ;

iteration_statement:
  WHILE "(" expr ")" statement {}
  | DO statement WHILE "(" expr ")" ";" {}
  | FOR "(" expr    ";" expr ";" expr ")" statement {}
  | FOR "(" expr    ";" expr ";"      ")" statement {}
  | FOR "(" expr    ";"      ";" expr ")" statement {}
  | FOR "("         ";" expr ";" expr ")" statement {}
  | FOR "(" expr    ";"      ";"      ")" statement {}
  | FOR "("         ";" expr ";"      ")" statement {}
  | FOR "("         ";"      ";" expr ")" statement {}
  | FOR "("         ";"      ";"      ")" statement {}
  | FOR "(" declaration expr ";" expr ")" statement {}
  | FOR "(" declaration expr ";"      ")" statement {}
  | FOR "(" declaration      ";" expr ")" statement {}
  | FOR "(" declaration      ";"      ")" statement {}
  ;

jump_statement:
  GOTO IDENTIFIER ";" {}
  | CONTINUE ";" {}
  | BREAK ";" {}
  | RETURN expr ";" {}
  | RETURN ';' {}
  ;

%%

