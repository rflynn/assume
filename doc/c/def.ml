(* ex: set ts=2 et: *)

open List;;

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
    (* this is not what we really want, as this allows the 'int'
     * type to change during runtime. what we want is really the
     * size of the builtin types, to be passed upon creation of 'C',
     * which then constructs the types in a fixed manner for the
     * remainder *)
    type cint     = CInt16  of int16
                  | CInt32  of int32
                  | CInt64  of int64;;

    type cfloat   = CFloat  of float;;
    type cstring  = CStr    of string;;

    type constant =
        IntConst    of cint
      | FloatConst  of cfloat
      | CharConst   of cchar
      ;;

    type type_name =
        EnumName   of string
      | StructName of string
      | UnionName  of string
      | TypeName   of string
      ;;

    let type_name_show tn =
      match tn with
        EnumName  (name) -> name
      | StructName(name) -> name
      | UnionName (name) -> name
      | TypeName  (name) -> name
      ;;

    type storage_class_specifier  = Typedef | Extern | Static | Auto | Register ;;
    type type_specifier           =
        Void
      | Char   of cchar
      | Int    of cint
      | Float  of cfloat
      | Struct of cident
      | Fun    of cident
      ;;
    type type_qualifier           = Const | Restrict | Volatile ;;
    type function_specifier       = Inline ;;
    type declaration_specifier    =
        StorClassSpec of storage_class_specifier
      | TypeSpec      of type_specifier
      | TypeQual      of type_qualifier
      | FuncSpec      of function_specifier
      ;;

    type parameter_type_list    = IdentList of cident list ;;

    type unary_expression ;; (* FIXME: TODO *)
    type conditional_expression ;; (* FIXME: TODO *)

    type assignment_operator    = string;; (* NOTE: we'll leave operators as strings, for now *)
    type assignment_expression  =
        AssignExprCond  of conditional_expression
      | AssignExprUnary of unary_expression * assignment_operator * assignment_expression
      ;;

    type pointer ;; (* FIXME: TODO *)
    type direct_declarator      =
        DDIdent       of cident
      | DDDeclarator  of declarator
      | DDDDArray     of direct_declarator * type_qualifier list * assignment_expression (* TODO: static *)
      | DDDDFuncParam of parameter_type_list
      | DDDDFuncIdent of cident list
    and declarator              =
        Declarator    of pointer * direct_declarator
      ;;

    type initializer_           =
        InitializerAssign   of assignment_expression
      | Initializer         of initializer_ list
      ;;
    type init_declarator        =
        InitDeclarator      of declarator
      | InitDeclaratorInit  of initializer_
    and  declaration            =
      Declaration           of declaration_specifier list * init_declarator list
      ;;

(*
(6.7.8) initializer:
                assignment-expression
                { initializer-list }
                { initializer-list , }
(6.7.8) initializer-list:
                designationopt initializer
                initializer-list , designationopt initializer
(6.7.8) designation:
                designator-list =
(6.7.8) designator-list:
                designator
                designator-list designator

(6.7) init-declarator:
               declarator
               declarator = initializer
(6.7.5) declarator:
               pointeropt direct-declarator
(6.7.5) direct-declarator:
               identifier
               ( declarator )
               direct-declarator [ type-qualifier-listopt assignment-expressionopt ]
               direct-declarator [ static type-qualifier-listopt assignment-expression ]
               direct-declarator [ type-qualifier-list static assignment-expression ]
               direct-declarator [ type-qualifier-listopt * ]
               direct-declarator ( parameter-type-list )
               direct-declarator ( identifier-listopt )
(6.7.5) pointer:
               * type-qualifier-listopt
               * type-qualifier-listopt pointer
(6.7.5) type-qualifier-list:
               type-qualifier
               type-qualifier-list type-qualifier
(6.7.5) parameter-type-list:
               parameter-list
               parameter-list , ...
(6.7.5) parameter-list:
               parameter-declaration
               parameter-list , parameter-declaration
(6.7.5) parameter-declaration:
               declaration-specifiers declarator
               declaration-specifiers abstract-declaratoropt
(6.7.5) identifier-list:
               identifier
               identifier-list , identifier
*)

