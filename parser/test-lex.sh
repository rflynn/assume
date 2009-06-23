#!/bin/bash
# run our lexer through tests based on the C99 standard

PassCnt=0
FailCnt=0

LEXER="./lex"

test_lex() {
  if [ $# -ne 3 ]
  then
    echo "test_lex wrong number of parameters \$1=$1 \$2=$2"
    exit 1
  fi
  id=$1
  input=$2
  expect=$3
  result=`echo "$input" | $LEXER 2>&1`
  if [ "$expect" == "$result" ]
  then
    PassCnt=$((PassCnt+1))
  else
    echo "Test $id failed:"
    echo "INPUT $input"
    echo "EXPECT <$expect>"
    echo "RESULT <$result>"
    echo ""
    FailCnt=$((FailCnt+1))
    if [ $FailCnt -gt 2 ]
    then
      exit 1
    fi
  fi
}

echo "Testing lexer..."

if [ ! -e $LEXER ]
then
  echo "$LEXER does not exist"
  exit 1
fi

test_lex '6.4.6 Punctuators'  '|'       '(|)\n'
test_lex '6.4.6 Punctuators'  '||'      '(||)\n'
test_lex '6.4.6 Punctuators'  '|||'     '(||)(|)\n'
test_lex '6.4.6 Punctuators'  '||=|'    '(|)(|=)(|)\n'


echo "FIXME: cpp multiline \ stuff broken, fix"

test_lex 'Whitespace' ' '       'ws( )\n'
test_lex 'Whitespace' "a b"     "ident(a)ws( )ident(b)\\n"
#test_lex 'Whitespace' "\f"      "whitespace(\f)"
#test_lex 'Whitespace' "\v"      "whitespace(\v)"
#test_lex 'Whitespace' "\r"      "whitespace(\r)"

echo "6.4.6 Punctuators"
test_lex '6.4.6 Punctuators'  '['       '([)\n'
test_lex '6.4.6 Punctuators'  ']'       '(])\n'
test_lex '6.4.6 Punctuators'  '.'       '(.)\n'
test_lex '6.4.6 Punctuators'  '->'      '(->)\n'
test_lex '6.4.6 Punctuators'  '>>='     '(>>=)\n'
test_lex '6.4.6 Punctuators'  '&&&&&'   "(&&)(&&)(&)\n"
#test_lex '6.4.6 Punctuators'  '##'      '##'
test_lex '6.4.6 Punctuators'  '+'       '(+)\n'
test_lex '6.4.6 Punctuators'  '++'      '(++)\n'
test_lex '6.4.6 Punctuators'  '+++'     '(++)(+)\n'
test_lex '6.4.6 Punctuators'  '--'      '(--)\n'
test_lex '6.4.6 Punctuators'  '--->>>'  "(--)(->)(>>)\n"
test_lex '6.4.6 Punctuators'  '<<<===>>>' "(<<)(<=)(==)(>>)(>)\n"
# since we are explicitly using regex, test punctuators that contain special regex characters
# for proper escapes
test_lex '6.4.6 Punctuators'  '['       '([)\n'
test_lex '6.4.6 Punctuators'  '[['      '([)([)\n'
test_lex '6.4.6 Punctuators'  ']'       '(])\n'
test_lex '6.4.6 Punctuators'  ']]'      '(])(])\n'
test_lex '6.4.6 Punctuators'  '[][]'    '([)(])([)(])\n'
test_lex '6.4.6 Punctuators'  '^'       '(^)\n'
test_lex '6.4.6 Punctuators'  '^^'      '(^)(^)\n'
test_lex '6.4.6 Punctuators'  '^^^'     '(^)(^)(^)\n'
test_lex '6.4.6 Punctuators'  '^='      '(^=)\n'
test_lex '6.4.6 Punctuators'  '^=^'     '(^=)(^)\n'
test_lex '6.4.6 Punctuators'  '?'       '(?)\n'
test_lex '6.4.6 Punctuators'  '??'      '(?)(?)\n'
test_lex '6.4.6 Punctuators'  '???'     '(?)(?)(?)\n'
test_lex '6.4.6 Punctuators'  '.'       '(.)\n'
test_lex '6.4.6 Punctuators'  '..'      '(.)(.)\n'
test_lex '6.4.6 Punctuators'  '...'     '(...)\n'
test_lex '6.4.6 Punctuators'  '....'    '(...)(.)\n'
test_lex '6.4.6 Punctuators'  '.....'   '(...)(.)(.)\n'
test_lex '6.4.6 Punctuators'  '......'  '(...)(...)\n'
# The program fragment x+++++y is parsed as x ++ ++ + y,
test_lex '6.4.1 Example 2' 'x+++++y'  'ident(x)(++)(++)(+)ident(y)\n'

echo "6.4.2 Identifiers"
test_lex '6.4.2 Identifiers' '_'                      'ident(_)\n'
test_lex '6.4.2 Identifiers' '__'                     'ident(__)\n'
test_lex '6.4.2 Identifiers' '___'                    'ident(___)\n'
test_lex '6.4.2 Identifiers' '_____________________'  'ident(_____________________)\n'
test_lex '6.4.2 Identifiers' '__FILE__'               'ident(__FILE__)\n'
test_lex '6.4.2 Identifiers' '__LINE__'               'ident(__LINE__)\n'
test_lex '6.4.2 Identifiers' '__func__'               'ident(__func__)\n'
test_lex '6.4.2 Identifiers' 'a'                      'ident(a)\n'
test_lex '6.4.2 Identifiers' '_0'                     'ident(_0)\n'
test_lex '6.4.2 Identifiers' '_a0'                    'ident(_a0)\n'
test_lex '6.4.2 Identifiers' '_a0a'                   'ident(_a0a)\n'

echo "6.4.3 Universal character names"
test_lex '6.4.2 Identifiers' '_\u0123'                'ident(_\u0123)\n'
test_lex '6.4.2 Identifiers' 'a\u4567'                'ident(a\u4567)\n'
test_lex '6.4.2 Identifiers' 'a\u0123\u4567'          'ident(a\u0123\u4567)\n'
test_lex '6.4.2 Identifiers' 'a\U01234567'            'ident(a\U01234567)\n'
test_lex '6.4.2 Identifiers' 'a\U01234567\u9ABC'      'ident(a\U01234567\u9ABC)\n'
test_lex '6.4.2 Identifiers' '_\U89ABCDEF\u9ABC'      'ident(_\U89ABCDEF\u9ABC)\n'

echo "6.4.4.3 Enum constants"
 
echo "6.4.5 Character constants"
test_lex '6.4.5 Character constants'  "''"          "char_lit('')\n"
test_lex '6.4.5 Character constants'  "L''"         "char_lit(L'')\n"
test_lex '6.4.5 Character constants'  "'\\x0'"       "char_lit('\\x0')\n"
test_lex '6.4.5 Character constants'  "'\\x00'"      "char_lit('\\x00')\n"
test_lex '6.4.5 Character constants'  "'\\x000'"     "char_lit('\\x000')\n"
test_lex '6.4.5 Character constants'  "'\\x0000'"    "char_lit('\\x0000')\n"
test_lex '6.4.5 Character constants'  "'\\a'"        "char_lit('\\a')\n"
test_lex '6.4.5 Character constants'  "'\\b'"        "char_lit('\\b')\n"
test_lex '6.4.5 Character constants'  "'\\f'"        "char_lit('\\f')\n"
test_lex '6.4.5 Character constants'  "'\\n'"        "char_lit('\\n')\n"
test_lex '6.4.5 Character constants'  "'\\r'"        "char_lit('\\r')\n"
test_lex '6.4.5 Character constants'  "'\\t'"        "char_lit('\\t')\n"
test_lex '6.4.5 Character constants'  "'\\v'"        "char_lit('\\v')\n"
test_lex '6.4.5 Character constants'  "'\\xA\\xB'"    "char_lit('\\xA\\xB')\n"
test_lex '6.4.5 empty string'         '""'          'str_lit("")\n'
test_lex '6.4.5 empty wide string'    'L""'         'str_lit(L"")\n'
test_lex '6.4.5 string'               '"a"'         'str_lit("a")\n'
test_lex '6.4.5 string escape'        '"\\\\"'      'str_lit("\\\\")\n'
test_lex '6.4.5 string escape'        '"\\\""'      'str_lit("\\\"")\n'

echo "6.4.1 Keywords"
test_lex '6.4.1 Keywords' 'auto'        'keyword(auto)\n'
test_lex '6.4.1 Keywords' 'break'       'keyword(break)\n'
test_lex '6.4.1 Keywords' 'case'        'keyword(case)\n'
test_lex '6.4.1 Keywords' 'char'        'keyword(char)\n'
test_lex '6.4.1 Keywords' 'const'       'keyword(const)\n'
test_lex '6.4.1 Keywords' 'continue'    'keyword(continue)\n'
test_lex '6.4.1 Keywords' 'default'     'keyword(default)\n'
test_lex '6.4.1 Keywords' 'do'          'keyword(do)\n'
test_lex '6.4.1 Keywords' 'double'      'keyword(double)\n'
test_lex '6.4.1 Keywords' 'else'        'keyword(else)\n'
test_lex '6.4.1 Keywords' 'enum'        'keyword(enum)\n'
test_lex '6.4.1 Keywords' 'extern'      'keyword(extern)\n'
test_lex '6.4.1 Keywords' 'float'       'keyword(float)\n'
test_lex '6.4.1 Keywords' 'for'         'keyword(for)\n'
test_lex '6.4.1 Keywords' 'goto'        'keyword(goto)\n'
test_lex '6.4.1 Keywords' 'if'          'keyword(if)\n'
test_lex '6.4.1 Keywords' 'inline'      'keyword(inline)\n'
test_lex '6.4.1 Keywords' 'int'         'keyword(int)\n'
test_lex '6.4.1 Keywords' 'long'        'keyword(long)\n'
test_lex '6.4.1 Keywords' 'register'    'keyword(register)\n'
test_lex '6.4.1 Keywords' 'restrict'    'keyword(restrict)\n'
test_lex '6.4.1 Keywords' 'return'      'keyword(return)\n'
test_lex '6.4.1 Keywords' 'short'       'keyword(short)\n'
test_lex '6.4.1 Keywords' 'signed'      'keyword(signed)\n'
test_lex '6.4.1 Keywords' 'sizeof'      'keyword(sizeof)\n'
test_lex '6.4.1 Keywords' 'static'      'keyword(static)\n'
test_lex '6.4.1 Keywords' 'struct'      'keyword(struct)\n'
test_lex '6.4.1 Keywords' 'switch'      'keyword(switch)\n'
test_lex '6.4.1 Keywords' 'typedef'     'keyword(typedef)\n'
test_lex '6.4.1 Keywords' 'union'       'keyword(union)\n'
test_lex '6.4.1 Keywords' 'unsigned'    'keyword(unsigned)\n'
test_lex '6.4.1 Keywords' 'void'        'keyword(void)\n'
test_lex '6.4.1 Keywords' 'volatile'    'keyword(volatile)\n'
test_lex '6.4.1 Keywords' 'while'       'keyword(while)\n'
test_lex '6.4.1 Keywords' '_Bool'       'keyword(_Bool)\n'
test_lex '6.4.1 Keywords' '_Complex'    'keyword(_Complex)\n'
test_lex '6.4.1 Keywords' '_Imaginary'  'keyword(_Imaginary)\n'

echo "6.4.4 Constants"

echo "6.4.4.1 Integer constants"
test_lex '6.4.4.1 Octal'    '0'       'int_lit(0)\n'
test_lex '6.4.4.1 Octal'    '00'      'int_lit(00)\n'
test_lex '6.4.4.1 Octal'    '01'      'int_lit(01)\n'
test_lex '6.4.4.1 Octal'    '02'      'int_lit(02)\n'
test_lex '6.4.4.1 Octal'    '03'      'int_lit(03)\n'
test_lex '6.4.4.1 Octal'    '04'      'int_lit(04)\n'
test_lex '6.4.4.1 Octal'    '05'      'int_lit(05)\n'
test_lex '6.4.4.1 Octal'    '06'      'int_lit(06)\n'
test_lex '6.4.4.1 Octal'    '07'      'int_lit(07)\n'
test_lex '6.4.4.1 Octal'    '08'      'int_lit(0)int_lit(8)\n'
test_lex '6.4.4.1 Octal'    '09'      'int_lit(0)int_lit(9)\n'
test_lex '6.4.4.1 Octal'    '0A'      'int_lit(0)ident(A)\n'
test_lex '6.4.4.1 Octal'    '8'      'int_lit(8)\n'
test_lex '6.4.4.1 Octal'    '9'      'int_lit(9)\n'
test_lex '6.4.4.1 Octal'    '0u'      'int_lit(0u)\n'
test_lex '6.4.4.1 Octal'    '0U'      'int_lit(0U)\n'
test_lex '6.4.4.1 Octal'    '0UL'     'int_lit(0UL)\n'
test_lex '6.4.4.1 Octal'    '0ul'     'int_lit(0ul)\n'
test_lex '6.4.4.1 Octal'    '0ULL'    'int_lit(0ULL)\n'
test_lex '6.4.4.1 Octal'    '0ull'    'int_lit(0ull)\n'
test_lex '6.4.4.1 Octal'    '0Ull'    'int_lit(0Ull)\n'
test_lex '6.4.4.1 Octal'    '0uLL'    'int_lit(0uLL)\n'
test_lex '6.4.4.1 Decimal'  '1'       'int_lit(1)\n'
test_lex '6.4.4.1 Decimal'  '2'       'int_lit(2)\n'
test_lex '6.4.4.1 Decimal'  '3'       'int_lit(3)\n'
test_lex '6.4.4.1 Decimal'  '4'       'int_lit(4)\n'
test_lex '6.4.4.1 Decimal'  '5'       'int_lit(5)\n'
test_lex '6.4.4.1 Decimal'  '6'       'int_lit(6)\n'
test_lex '6.4.4.1 Decimal'  '7'       'int_lit(7)\n'
test_lex '6.4.4.1 Decimal'  '8'       'int_lit(8)\n'
test_lex '6.4.4.1 Decimal'  '9'       'int_lit(9)\n'
test_lex '6.4.4.1 Decimal'  '1u'      'int_lit(1u)\n'
test_lex '6.4.4.1 Decimal'  '1U'      'int_lit(1U)\n'
test_lex '6.4.4.1 Decimal'  '1UL'     'int_lit(1UL)\n'
test_lex '6.4.4.1 Decimal'  '1ul'     'int_lit(1ul)\n'
test_lex '6.4.4.1 Decimal'  '1ULL'    'int_lit(1ULL)\n'
test_lex '6.4.4.1 Decimal'  '1ull'    'int_lit(1ull)\n'
test_lex '6.4.4.1 Decimal'  '1Ull'    'int_lit(1Ull)\n'
test_lex '6.4.4.1 Decimal'  '1uLL'    'int_lit(1uLL)\n'

echo "6.4.4.2 Floating constants"
test_lex '6.4.4.2 Floating constant'        '0.'                'float_lit(0.)\n'
test_lex '6.4.4.2 Floating constant'        '0.0'               'float_lit(0.0)\n'
test_lex '6.4.4.2 Floating constant'        '.0'                'float_lit(.0)\n'
test_lex '6.4.4.2 Floating constant suffix' '0.f'               'float_lit(0.f)\n'
test_lex '6.4.4.2 Floating constant suffix' '0.l'               'float_lit(0.l)\n'
test_lex '6.4.4.2 Floating constant suffix' '0.F'               'float_lit(0.F)\n'
test_lex '6.4.4.2 Floating constant suffix' '0.L'               'float_lit(0.L)\n'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'float_lit(0.1f)\n'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'float_lit(0.1f)\n'
test_lex '6.4.4.2 Floating constant (hex)'  '0x0.0p+0'          'float_lit(0x0.0p+0)\n'
test_lex '6.4.4.2 Floating constant (hex)'  '0x1.1p-1'          'float_lit(0x1.1p-1)\n'
test_lex '6.4.4.2 Floating constant (hex)'  '0x2.2p-2f'         'float_lit(0x2.2p-2f)\n'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.3p-3L'         'float_lit(0x3.3p-3L)\n'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.243F6A88p+03'  'float_lit(0x3.243F6A88p+03)\n'
test_lex '6.4.4.2 Floating constant'        '0e0'               'float_lit(0e0)\n'
test_lex '6.4.4.2 Floating constant'        '0e+0'              'float_lit(0e+0)\n'
test_lex '6.4.4.2 Floating constant'        '0e-0'              'float_lit(0e-0)\n'

echo "6.4.9 Comments"
test_lex '6.4.9 Comments (c-style)' "/**/" "comment(/**/)\n"
test_lex '6.4.9 Comments (c-style)' "/**** */" "comment(/**** */)\n"
test_lex '6.4.9 Comments (c-style)' "/* */" "comment(/* */)\n"
test_lex '6.4.9 Comments (c-style, embedded)' "/* /* */ */" "comment(/* /* */)ws( )(*)(/)\n"
test_lex '6.4.9 Comments (cplusplus easy)' "//" "comment(//
)"
test_lex '6.4.9 Comments (nested cplusplus)' '/*//*/' "comment(/*//*/)\n"
test_lex '6.4.9 Comments (nested c)' '///* */' "comment(///* */
)"
test_lex '6.4.9 Comments c-style, string nested' '"/**/"' 'str_lit("/**/")\n'
test_lex '6.4.9 Comments c++-style, string nested' '"//"' 'str_lit("//")\n'
test_lex '6.4.9 Comments c++-style, string nested' '"/"' 'str_lit("/")\n'
test_lex '6.4.9 Comments c++-style, string nested' '"///"' 'str_lit("///")\n'
test_lex '6.4.9 #3 Example' '"a//b"'            'str_lit("a//b")\n'
test_lex '6.4.9 #3 Example' '#include "//e"'    "cpp(#include \"//e\"
)"
test_lex '6.4.9 #3 Example' '// */'             "comment(// */
)"
test_lex '6.4.9 #3 Example' 'f = g/**//h;'      "ident(f)ws( )(=)ws( )ident(g)comment(/**/)(/)ident(h)(;)\\n"
#test_lex '6.4.9 #3 Example' "//\\
#i();" "comment(//\\
#i();
#)"
#test_lex '6.4.9 #3 Example' "/\\
#/ j();" "comment(/\\
#/ j();
#)"
test_lex '6.4.9 #3 Example' "/*//*/ l();" "comment(/*//*/)ws( )ident(l)(()())(;)\\n"
test_lex '6.4.9 #3 Example' "m=n//**/o
+ p;" "ident(m)(=)ident(n)comment(//**/o
)(+)ws( )ident(p)(;)\\n"
#test_lex '6.4.9 #3 Multiline test 1' "/\\
#/\\
#//" "comment(/\\
#/\\
#//
#)"
#test_lex '6.4.9 #3 Multiline test 1' "/\\
#/\\
#//
#/\\
#/" "comment(/\\
#/\\
#//
#/\\
#/
#)"
test_lex "? cpp (#include h-chars)" '#include "<foo>"' "cpp(#include \"<foo>\"
)"
test_lex "? cpp (#include q-chars)" '#include <"foo">' "cpp(#include <\"foo\">
)"
test_lex "? macro lone #" "#" "cpp(#
)"
#test_lex "? macro # and \\" "#\\
#" "cpp(#\\
#
#)"
#test_lex "? macro (multi \\ lines)" "#\\
#\\
#" "cpp(#\\
#\\
#
#)"
#test_lex '? macro (simple #define)' "#define X" "cpp(#define X
#)"
#test_lex '? macro (#define and \\)' "#define X \\
#Y" "cpp(#define X \\
#Y
#)"


######## end test cases, report

TotalCnt=$((PassCnt+FailCnt))

echo "Pass $PassCnt/$TotalCnt"
echo "(" `echo \`echo $PassCnt/$TotalCnt | bc -l | cut -b 1-5\` "*100" | bc -l` "%)"

if [ $FailCnt -eq 0 ]
then
  echo "Passed."
else
  echo "Failed!!!"
fi

