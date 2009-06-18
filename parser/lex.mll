(* ex: set ts=2 et: *)
(* Parser for C Programming Language, standard ISO 9899 *)
(* References
  #1 ISO/IEC International 9899 STANDARD
     Second Edition 1999-12-01
     Programming Languages -- C
     9899:1999(E)
*)

{
  open Printf
}

(* Ref ??? *)
(* macros may span multiple lines *)
let macro                         = ([^ '\n']* '\\' '\n')* [^ '\n']* '\n'

(* FIXME: add '\v' '\f' *)
let whitespace                    = [' ' '\t']

(* Ref #1 S6.4.4.1 Integer constants *)
let nondigit                      = ['_' 'a'-'z' 'A'-'Z']
let digit                         = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9']
let octal_prefix                  = '0'
let hexadecimal_prefix            = '0' ['x' 'X']
let nonzero_digit                 = [    '1' '2' '3' '4' '5' '6' '7' '8' '9']
let octal_digit                   = ['0' '1' '2' '3' '4' '5' '6' '7']
let hexadecimal_digit             = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9'
                                     'a' 'b' 'c' 'd' 'e' 'f'
                                     'A' 'B' 'C' 'D' 'E' 'F']
let unsigned_suffix               = ['u' 'U']
let long_suffix                   = ['l' 'L']
let long_long_suffix              = ("ll" | "LL")
let integer_suffix                = (unsigned_suffix (long_suffix | long_long_suffix)?
                                    | long_suffix unsigned_suffix?
                                    | long_long_suffix unsigned_suffix?)

(* Ref #1 S6.4.3 Universal character names *)
let hex_quad                      = (hexadecimal_digit hexadecimal_digit
                                      hexadecimal_digit hexadecimal_digit)
let universal_character_name      = '\\' ('u' hex_quad | 'U' hex_quad hex_quad)
let identifier                    = nondigit (nondigit | digit | universal_character_name)*


(* Ref #1 S6.4.4.2 Floating constants *)
let digit_sequence                = (digit+)
let floating_suffix               = ['f' 'l' 'F' 'L']
let sign                          = ['+' '-']
let exponent_part                 = (['e' 'E'] sign? digit_sequence)
let hexadecimal_digit_sequence    = (hexadecimal_digit+)
let binary_exponent_part          = (['p' 'P'] sign? digit_sequence)
let hexadecimal_fractional_constant
                                  = (hexadecimal_digit_sequence? '.' hexadecimal_digit_sequence
                                    | hexadecimal_digit_sequence '.')
let fractional_constant           = (digit_sequence? '.' digit_sequence
                                    | digit_sequence '.')
let hexadecimal_floating_constant = (hexadecimal_prefix hexadecimal_fractional_constant binary_exponent_part floating_suffix?
                                    | hexadecimal_prefix hexadecimal_digit_sequence binary_exponent_part floating_suffix?)
let decimal_floating_constant     = (fractional_constant exponent_part? floating_suffix?
                                    | digit_sequence exponent_part floating_suffix?)
let floating_constant             = (decimal_floating_constant | hexadecimal_floating_constant)

(* Ref #1 S6.4.4.4 Character constants *)
let simple_escape_sequence        = ('\\' ['\'' '"' '?' '\\' 'a' 'b' 'f' 'n' 'r' 't' 'v'])
let octal_escape_sequence         = ('\\' octal_digit octal_digit? octal_digit?)
let hexadecimal_escape_sequence   = ('\\' 'x' hexadecimal_digit)+
let escape_sequence               = (simple_escape_sequence
                                    | octal_escape_sequence
                                    | hexadecimal_escape_sequence
                                    | universal_character_name)
let c_char_sequence               = ([^ '\'' '\\' '\n'] | escape_sequence)
let character_constant            = 'L'? '\'' c_char_sequence* '\''

(* Ref #1 S6.4.5 String literals *)
let schar                         = ([^ '"' '\\' '\n'] | escape_sequence)
let string_literal                = 'L'? '"' schar* '"'

(* Ref #1 S6.4.6 Punctuators *)
let punctuator                    = ( "["   | "]"   | "("  | ")"  | "{"  | "}" | "."  | "->"
                                    | "++"  | "--"  | "&"  | "*"  | "+"  | "-" | "~"  | "!"
                                    | "/"   | "%"   | "<<" | ">>" | "<"  | ">" | "<=" | ">="
                                    | "=="  | "!="  | "^"  | "|"  | "&&" | "||"
                                    | "?"   | ":"   | ";"  | "..."
                                    | "="   | "*="  | "/=" | "%=" | "+=" | "-="
                                    | "<<=" | ">>=" | "&=" | "^=" | "|="
                                    | ","   | "#"   | "##"
                                    | "<:"  | ":>"  | "<%" | "%>" | "%:" | "%:%:")

(* Ref #1 S6.4.7 Header names *)
let header_name                   = ( '<' [^ '>' '\n']+ '>'
                                    | '"' [^ '"' '\n']+ '"')
(* Ref #1 S6.4.8 Processing numbers *)
(* WTF are processing numbers anyways? *)
let pp_number                     = '.'? digit+ nondigit* (['e' 'E' 'p' 'P'] sign)?

(* Ref #1 S6.4.9 Comments *)
let multiline_comment             = "/*" _* "*/"
(* NOTE: comment sequences may be split in half by a '\' '\n' sequence; and
 * and comment ending with said sequence continues to the next line *)
let cplusplus_comment             = (("//" | '/' '\\' '\n' '/') [^ '\n']* ('\n' | '\\' '\n' [^ '\n']* '\n'))+
let comment                       = multiline_comment | cplusplus_comment

rule c99 = parse
  | whitespace* "#" ([^ '#'] (macro)* | "\n") as cpp 
    {
      printf "preprocessor(%s)\n" cpp;
      c99 lexbuf
    }
  | ['\n']
    {
      (* NOTE: preprocessor and comments can absorb \n too *)
      c99 lexbuf
    }
  | whitespace+ as sp
    {
      printf "whitespace(%s)\n" sp;
      c99 lexbuf
    }
  | comment as c
    {
      printf "comment(%s)\n" c;
      c99 lexbuf
    }
  | floating_constant as fp
    {
      printf "floating_constant(%s)\n" fp;
      c99 lexbuf
    }
  | octal_prefix octal_digit* integer_suffix? as oct
    {
      printf "octal_constant(%s)\n" oct;
      c99 lexbuf
    }
  | nonzero_digit digit* integer_suffix? as dec
    {
      printf "decimal_constant(%s)\n" dec;
      c99 lexbuf
    }
  | hexadecimal_prefix hexadecimal_digit+ integer_suffix? as hex
    {
      printf "hexadecimal_constant(%s)\n" hex;
      c99 lexbuf
    }

  (* Ref 6.4.1 Keywords *)
  | "auto"
  | "break"
  | "case"
  | "char"
  | "const"
  | "continue"
  | "default"
  | "do"
  | "double"
  | "else"
  | "enum"
  | "extern"
  | "float"
  | "for"
  | "goto"
  | "if"
  | "inline"
  | "int"
  | "long"
  | "register"
  | "restrict"
  | "return"
  | "short"
  | "signed"
  | "sizeof"
  | "static"
  | "struct"
  | "switch"
  | "typedef"
  | "union"
  | "unsigned"
  | "void"
  | "volatile"
  | "while"
  | "_Bool"
  | "_Complex"
  | "_Imaginary" as keyword
    {
      printf "keyword(%s)\n" keyword;
      c99 lexbuf
    }

  | punctuator as p
    {
      printf "punctuator(%s)\n" p;
      c99 lexbuf
    }
  | identifier as id
    {
      (* TODO: check length *)
      printf "identifier(%s)\n" id;
      c99 lexbuf
    }
  | string_literal as str
    {
      (* TODO: check length *)
      printf "string_literal(%s)\n" str;
      c99 lexbuf
    }
  | character_constant as chr
    {
      (* TODO: check length *)
      printf "character_constant(%s)\n" chr;
      c99 lexbuf
    }
  | _ as c
    {
      printf "Unrecognized(%c)\n" c;
      c99 lexbuf
    }
  | eof
    {
    }

{
  let main () =
    let cin =
      if Array.length Sys.argv > 1
      then open_in Sys.argv.(1)
      else stdin
    in
    let lexbuf = Lexing.from_channel cin in
    c99 lexbuf

  let _ = Printexc.print main ()
}

