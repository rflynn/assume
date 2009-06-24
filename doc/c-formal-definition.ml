(* ex: set ts=2 et: *)

(* Provided by Theory *)
  
  (* type *)
  (* domain *)
  (* integer *)
  (* {set} *)
  (* (tuple) *)
  (* [list] *)
  (* <vector(type t,int cnt)> *)
  type 'a vector = Vector of 'a list;;

(* Provided by BinaryComputing: *)

  (* type () = () *)
  type bit      = Zero | One;;
  type bitv     = Bitv  of bit vector;;
  type int8     = Int8  of bitv;;
  type int16    = Int16 of bitv;;
  type int32    = Int32 of bitv;;
  type int64    = Int64 of bitv;;

(* Definition of the C Programming Language *)
  
    type cident   = Ident   of string;;
    type cchar    = CChar   of char;;
    type cint     = CInt16  of int16
                  | CInt32  of int32
                  | CInt64  of int64;;
    type cfloat   = CFloat  of float;;
    type cstring  = CStr    of string;;

    type constant =
        IntegerConstant   of cint
      | FloatingConstant  of cfloat
      | CharacterConstant of cchar
      ;;


(*
(6.5.2) postfix-expression:
primary-expression
postfix-expression [ expression ]
postfix-expression ( argument-expression-listopt )
postfix-expression . identifier
postfix-expression -> identifier
postfix-expression ++
postfix-expression --
( type-name ) { initializer-list }
( type-name ) { initializer-list , }

(6.5.2) argument-expression-list:
assignment-expression
argument-expression-list , assignment-expression

(6.5.3) unary-expression:
postfix-expression
++ unary-expression
-- unary-expression
unary-operator cast-expression
sizeof unary-expression
sizeof ( type-name )

(6.5.3) unary-operator: one of
& * + - ~ !

(6.5.4) cast-expression:
unary-expression
( type-name ) cast-expression

(6.5.5) multiplicative-expression:
cast-expression
multiplicative-expression * cast-expression
multiplicative-expression / cast-expression
multiplicative-expression % cast-expression

(6.5.6) additive-expression:
multiplicative-expression
additive-expression + multiplicative-expression
additive-expression - multiplicative-expression

(6.5.7) shift-expression:
additive-expression
shift-expression << additive-expression
shift-expression >> additive-expression

(6.5.8) relational-expression:
shift-expression
relational-expression < shift-expression
relational-expression > shift-expression
relational-expression <= shift-expression
relational-expression >= shift-expression

(6.5.9) equality-expression:
relational-expression
equality-expression == relational-expression
equality-expression != relational-expression

(6.5.10) AND-expression:
equality-expression
AND-expression & equality-expression

(6.5.11) exclusive-OR-expression:
AND-expression
exclusive-OR-expression ^ AND-expression

(6.5.12) inclusive-OR-expression:
exclusive-OR-expression
inclusive-OR-expression | exclusive-OR-expression

(6.5.13) logical-AND-expression:
inclusive-OR-expression
logical-AND-expression && inclusive-OR-expression

(6.5.14) logical-OR-expression:
logical-AND-expression
logical-OR-expression || logical-AND-expression

(6.5.15) conditional-expression:
logical-OR-expression
logical-OR-expression ? expression : conditional-expression

(6.5.16) assignment-expression:
conditional-expression
unary-expression assignment-operator assignment-expression

(6.5.16) assignment-operator: one of
= *= /= %= += -= <<= >>= &= ^= |=

(6.5.17) expression:
assignment-expression
expression , assignment-expression

(6.6) constant-expression:
conditional-expression
     *)

    type unary_operator     = Band | Mul | Plus | Minus | Bnot | Not;;

    type storage_class_specifier = Typedef | Extern | Static | Auto | Register;;

    type type_specifier     =
        Void
      | Char   of cchar
      | Int    of cint
      | Float  of cfloat
      | Struct of cident
      | Fun    of cident
      ;;

    type type_qualifier     =
      Const | Restrict | Volatile
      ;;

    type function_specifier =
      None | Inline
      ;;

    (*
     * hmm, can't really use the standard's definition,
     * BNF-style syntax doesn't work in OCaml because Ocaml
     * can't do forward references of types
     *)
    type expr =
        Constant of string
      | Variable of string
      | Cast     of string * expr
      | Unary    of string * expr
      | Binary   of expr * string * expr
      | Ternary  of expr * expr * expr
      | Assign   of expr * string * expr
      ;;

    (*
    type binary_expression =
      

    type assignment_expression =
      AssignmentExpr unary_expression * assignment_operator * conditional_expression
      ;;

    type expression =
      ExprAssignment assignment_expression
      ;;

    type conditional_expression =
      CondExpr expression
      | Ternary expression * conditional_expression
      ;;

    type primary_expression =
        PriExprIdent of cidentifier
      | PriExprConst of constant
      | PriExprStr   of cstring
      | PriExprExpr  of expression
      ;;
    *)



    

    (* A.2.3 Statements *)
    (*
    type statement = 
      labeled_statement
      | compound_statement
      | expression_statement
      | selection_statement
      | iteration_statement
      | jump_statement
      ;;

    type labeled_statement =
      Label_Stmt_Ident of identifier * statement
      | Case constant_expression * statement
      | Default statement
      ;;

    type compound-statement =
      Block_Item_List [block_item]
      ;;
    *)
    (*

    type block-item:
declaration
statement
(6.8.3) expression-statement:
expressionopt ;
(6.8.4) selection-statement:
if ( expression ) statement
if ( expression ) statement else statement
switch ( expression ) statement
(6.8.5) iteration-statement:
while ( expression ) statement
do statement while ( expression ) ;
for ( expressionopt ; expressionopt ; expressionopt ) statement
for ( declaration expressionopt ; expressionopt ) statement

    type 

    *)

    (* A.2.4 External definitions *)
    (*
    type translation_unit = 
      Tran_Unit of [external_declaration]
      ;;

    type external_declaration =
      Ext_Dec_Fun function_definition
      | Ext_Decl declaration
      ;;

    type function_definition =
      Function_Definition declaration_specifiers declarator [declaration] compound_statement
      ;;
    *)

