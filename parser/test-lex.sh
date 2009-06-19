#!/bin/bash

PassCnt=0
FailCnt=0

test_lex() {
  if [ $# -ne 3 ]
  then
    echo "test_lex wrong number of parameters \$1=$1 \$2=$2"
    exit 1
  fi
  id=$1
  input=$2
  expect=$3
  result=`echo "$input" | ocaml lex.ml 2>&1`
  if [ "$expect" == "$result" ]
  then
    PassCnt=$((PassCnt+1))
  else
    echo "Test $id failed:"
    echo "INPUT $input"
    echo "EXPECT $expect"
    echo "RESULT $result\n"
    FailCnt=$((FailCnt+1))
  fi
}

echo "Making..."

make
if [ $? -ne 0 ]
then
  echo "Make failed"
  exit 1
fi

echo "Testing lexer..."

test_lex 'Whitespace' ' '       'whitespace( )'
test_lex 'Whitespace' "a	b"    "identifier(a)
whitespace(	)
identifier(b)"

# test form feed character "\f"
test_lex 'Whitespace' "a$(printf \\013)b" "identifier(a)
whitespace($(printf \\013))
identifier(b)"

# test vertical tab character "\v"
test_lex 'Whitespace' "a$(printf \\014)b" "identifier(a)
whitespace($(printf \\014))
identifier(b)"

# test return character "\r"
test_lex 'Whitespace' "a$(printf \\011)b" "identifier(a)
whitespace($(printf \\011))
identifier(b)"

echo "6.4.1 Keywords"
test_lex '6.4.1 Keywords' 'auto'        'keyword(auto)'
test_lex '6.4.1 Keywords' 'break'       'keyword(break)'
test_lex '6.4.1 Keywords' 'case'        'keyword(case)'
test_lex '6.4.1 Keywords' 'char'        'keyword(char)'
test_lex '6.4.1 Keywords' 'const'       'keyword(const)'
test_lex '6.4.1 Keywords' 'continue'    'keyword(continue)'
test_lex '6.4.1 Keywords' 'default'     'keyword(default)'
test_lex '6.4.1 Keywords' 'do'          'keyword(do)'
test_lex '6.4.1 Keywords' 'double'      'keyword(double)'
test_lex '6.4.1 Keywords' 'else'        'keyword(else)'
test_lex '6.4.1 Keywords' 'enum'        'keyword(enum)'
test_lex '6.4.1 Keywords' 'extern'      'keyword(extern)'
test_lex '6.4.1 Keywords' 'float'       'keyword(float)'
test_lex '6.4.1 Keywords' 'for'         'keyword(for)'
test_lex '6.4.1 Keywords' 'goto'        'keyword(goto)'
test_lex '6.4.1 Keywords' 'if'          'keyword(if)'
test_lex '6.4.1 Keywords' 'inline'      'keyword(inline)'
test_lex '6.4.1 Keywords' 'int'         'keyword(int)'
test_lex '6.4.1 Keywords' 'long'        'keyword(long)'
test_lex '6.4.1 Keywords' 'register'    'keyword(register)'
test_lex '6.4.1 Keywords' 'restrict'    'keyword(restrict)'
test_lex '6.4.1 Keywords' 'return'      'keyword(return)'
test_lex '6.4.1 Keywords' 'short'       'keyword(short)'
test_lex '6.4.1 Keywords' 'signed'      'keyword(signed)'
test_lex '6.4.1 Keywords' 'sizeof'      'keyword(sizeof)'
test_lex '6.4.1 Keywords' 'static'      'keyword(static)'
test_lex '6.4.1 Keywords' 'struct'      'keyword(struct)'
test_lex '6.4.1 Keywords' 'switch'      'keyword(switch)'
test_lex '6.4.1 Keywords' 'typedef'     'keyword(typedef)'
test_lex '6.4.1 Keywords' 'union'       'keyword(union)'
test_lex '6.4.1 Keywords' 'unsigned'    'keyword(unsigned)'
test_lex '6.4.1 Keywords' 'void'        'keyword(void)'
test_lex '6.4.1 Keywords' 'volatile'    'keyword(volatile)'
test_lex '6.4.1 Keywords' 'while'       'keyword(while)'
test_lex '6.4.1 Keywords' '_Bool'       'keyword(_Bool)'
test_lex '6.4.1 Keywords' '_Complex'    'keyword(_Complex)'
test_lex '6.4.1 Keywords' '_Imaginary'  'keyword(_Imaginary)'

echo "6.4.2 Identifiers"
test_lex '6.4.2 Identifiers' '_'                      'identifier(_)'
test_lex '6.4.2 Identifiers' '__'                     'identifier(__)'
test_lex '6.4.2 Identifiers' '___'                    'identifier(___)'
test_lex '6.4.2 Identifiers' '_____________________'  'identifier(_____________________)'
test_lex '6.4.2 Identifiers' '__FILE__'               'identifier(__FILE__)'
test_lex '6.4.2 Identifiers' '__LINE__'               'identifier(__LINE__)'
test_lex '6.4.2 Identifiers' '__func__'               'identifier(__func__)'
test_lex '6.4.2 Identifiers' 'a'                      'identifier(a)'
test_lex '6.4.2 Identifiers' '_0'                     'identifier(_0)'
test_lex '6.4.2 Identifiers' '_a0'                    'identifier(_a0)'
test_lex '6.4.2 Identifiers' '_a0a'                   'identifier(_a0a)'

echo "6.4.3 Universal character names"
test_lex '6.4.2 Identifiers' '_\u0123'                'identifier(_\u0123)'
test_lex '6.4.2 Identifiers' 'a\u4567'                'identifier(a\u4567)'
test_lex '6.4.2 Identifiers' 'a\u0123\u4567'          'identifier(a\u0123\u4567)'
test_lex '6.4.2 Identifiers' 'a\U01234567'            'identifier(a\U01234567)'
test_lex '6.4.2 Identifiers' 'a\U01234567\u9ABC'      'identifier(a\U01234567\u9ABC)'
test_lex '6.4.2 Identifiers' '_\U89ABCDEF\u9ABC'      'identifier(_\U89ABCDEF\u9ABC)'

echo "6.4.4 Constants"

echo "6.4.4.1 Integer constants"
test_lex '6.4.4.1 Octal'    '0'       'octal_constant(0)'
test_lex '6.4.4.1 Octal'    '00'      'octal_constant(00)'
test_lex '6.4.4.1 Octal'    '01'      'octal_constant(01)'
test_lex '6.4.4.1 Octal'    '02'      'octal_constant(02)'
test_lex '6.4.4.1 Octal'    '03'      'octal_constant(03)'
test_lex '6.4.4.1 Octal'    '04'      'octal_constant(04)'
test_lex '6.4.4.1 Octal'    '05'      'octal_constant(05)'
test_lex '6.4.4.1 Octal'    '06'      'octal_constant(06)'
test_lex '6.4.4.1 Octal'    '07'      'octal_constant(07)'
test_lex '6.4.4.1 Octal'    '08'      'octal_constant(0)
decimal_constant(8)'
test_lex '6.4.4.1 Octal'    '09'      'octal_constant(0)
decimal_constant(9)'
test_lex '6.4.4.1 Octal'    '0A'      'octal_constant(0)
identifier(A)'
test_lex '6.4.4.1 Octal'    '0u'      'octal_constant(0u)'
test_lex '6.4.4.1 Octal'    '0U'      'octal_constant(0U)'
test_lex '6.4.4.1 Octal'    '0UL'     'octal_constant(0UL)'
test_lex '6.4.4.1 Octal'    '0ul'     'octal_constant(0ul)'
test_lex '6.4.4.1 Octal'    '0ULL'    'octal_constant(0ULL)'
test_lex '6.4.4.1 Octal'    '0ull'    'octal_constant(0ull)'
test_lex '6.4.4.1 Octal'    '0Ull'    'octal_constant(0Ull)'
test_lex '6.4.4.1 Octal'    '0uLL'    'octal_constant(0uLL)'
test_lex '6.4.4.1 Decimal'  '1'       'decimal_constant(1)'
test_lex '6.4.4.1 Decimal'  '2'       'decimal_constant(2)'
test_lex '6.4.4.1 Decimal'  '3'       'decimal_constant(3)'
test_lex '6.4.4.1 Decimal'  '4'       'decimal_constant(4)'
test_lex '6.4.4.1 Decimal'  '5'       'decimal_constant(5)'
test_lex '6.4.4.1 Decimal'  '6'       'decimal_constant(6)'
test_lex '6.4.4.1 Decimal'  '7'       'decimal_constant(7)'
test_lex '6.4.4.1 Decimal'  '8'       'decimal_constant(8)'
test_lex '6.4.4.1 Decimal'  '9'       'decimal_constant(9)'
test_lex '6.4.4.1 Decimal'  '1u'      'decimal_constant(1u)'
test_lex '6.4.4.1 Decimal'  '1U'      'decimal_constant(1U)'
test_lex '6.4.4.1 Decimal'  '1UL'     'decimal_constant(1UL)'
test_lex '6.4.4.1 Decimal'  '1ul'     'decimal_constant(1ul)'
test_lex '6.4.4.1 Decimal'  '1ULL'    'decimal_constant(1ULL)'
test_lex '6.4.4.1 Decimal'  '1ull'    'decimal_constant(1ull)'
test_lex '6.4.4.1 Decimal'  '1Ull'    'decimal_constant(1Ull)'
test_lex '6.4.4.1 Decimal'  '1uLL'    'decimal_constant(1uLL)'

echo "6.4.4.2 Floating constants"
test_lex '6.4.4.2 Floating constant'        '0.'                'floating_constant(0.)'
test_lex '6.4.4.2 Floating constant'        '0.0'               'floating_constant(0.0)'
test_lex '6.4.4.2 Floating constant'        '.0'                'floating_constant(.0)'
test_lex '6.4.4.2 Floating constant suffix' '0.f'               'floating_constant(0.f)'
test_lex '6.4.4.2 Floating constant suffix' '0.l'               'floating_constant(0.l)'
test_lex '6.4.4.2 Floating constant suffix' '0.F'               'floating_constant(0.F)'
test_lex '6.4.4.2 Floating constant suffix' '0.L'               'floating_constant(0.L)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'floating_constant(0.1f)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'floating_constant(0.1f)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x0.0p+0'          'floating_constant(0x0.0p+0)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x1.1p-1'          'floating_constant(0x1.1p-1)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x2.2p-2f'         'floating_constant(0x2.2p-2f)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.3p-3L'         'floating_constant(0x3.3p-3L)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.243F6A88p+03'  'floating_constant(0x3.243F6A88p+03)'
test_lex '6.4.4.2 Floating constant'        '0e0'               'floating_constant(0e0)'
test_lex '6.4.4.2 Floating constant'        '0e+0'              'floating_constant(0e+0)'
test_lex '6.4.4.2 Floating constant'        '0e-0'              'floating_constant(0e-0)'

echo "6.4.4.3 Enum constants"

echo "6.4.5 Character constants"
test_lex '6.4.5 Character constants'  "''"          "character_constant('')"
test_lex '6.4.5 Character constants'  "L''"         "character_constant(L'')"
test_lex '6.4.5 Character constants'  "'\x0'"       "character_constant('\x0')"
test_lex '6.4.5 Character constants'  "'\x00'"      "character_constant('\x00')"
test_lex '6.4.5 Character constants'  "'\x000'"     "character_constant('\x000')"
test_lex '6.4.5 Character constants'  "'\x0000'"    "character_constant('\x0000')"
test_lex '6.4.5 Character constants'  "'\a'"        "character_constant('\a')"
test_lex '6.4.5 Character constants'  "'\b'"        "character_constant('\b')"
test_lex '6.4.5 Character constants'  "'\f'"        "character_constant('\f')"
test_lex '6.4.5 Character constants'  "'\n'"        "character_constant('\n')"
test_lex '6.4.5 Character constants'  "'\r'"        "character_constant('\r')"
test_lex '6.4.5 Character constants'  "'\t'"        "character_constant('\t')"
test_lex '6.4.5 Character constants'  "'\v'"        "character_constant('\v')"
test_lex '6.4.5 Character constants'  "'\xA\xB'"    "character_constant('\xA\xB')"
test_lex '6.4.5 empty string'         '""'          'string_literal("")'
test_lex '6.4.5 empty wide string'    'L""'         'string_literal(L"")'
test_lex '6.4.5 string'               '"a"'         'string_literal("a")'
test_lex '6.4.5 string escape'        '"\\\\"'      'string_literal("\\\\")'
test_lex '6.4.5 string escape'        '"\\\""'      'string_literal("\\\"")'

echo "6.4.6 Punctuators"
test_lex '6.4.6 Punctuators'  '['     'punctuator([)'
test_lex '6.4.6 Punctuators'  ']'     'punctuator(])'
test_lex '6.4.6 Punctuators'  '.'     'punctuator(.)'
test_lex '6.4.6 Punctuators'  '->'    'punctuator(->)'
test_lex '6.4.6 Punctuators'  '>>='   'punctuator(>>=)'
test_lex '6.4.6 Punctuators'  '##'    'punctuator(##)'
test_lex '6.4.6 Punctuators'  '+'     'punctuator(+)'
test_lex '6.4.6 Punctuators'  '++'    'punctuator(++)'
test_lex '6.4.6 Punctuators'  '+++'   'punctuator(++)
punctuator(+)'
test_lex '6.4.6 Punctuators'  '--'    'punctuator(--)'
# The program fragment x+++++y is parsed as x ++ ++ + y,
test_lex '6.4.1 Example 2' 'x+++++y'  'identifier(x)
punctuator(++)
punctuator(++)
punctuator(+)
identifier(y)'

test_lex '6.4.9 Comments (c-style)' "/**/" "comment(/**/)"
test_lex '6.4.9 Comments (c-style)' "/**** */" "comment(/**** */)"
test_lex '6.4.9 Comments (c-style)' "/* */" "comment(/* */)"
test_lex '6.4.9 Comments (c-style)' "/* /* */ */" "comment(/* /* */ */)"
test_lex '6.4.9 Comments (cplusplus easy)' "//" "comment(//
)"
test_lex '6.4.9 Comments (nested cplusplus)' '/*//*/' "comment(/*//*/)"
test_lex '6.4.9 Comments (nested c)' '///* */' "comment(///* */
)"
test_lex '6.4.9 Comments c-style, string nested' '"/**/"' 'string_literal("/**/")'
test_lex '6.4.9 Comments c++-style, string nested' '"//"' 'string_literal("//")'
test_lex '6.4.9 Comments c++-style, string nested' '"/"' 'string_literal("/")'
test_lex '6.4.9 Comments c++-style, string nested' '"///"' 'string_literal("///")'
test_lex '6.4.9 #3 Example' '"a//b"'            'string_literal("a//b")'
test_lex '6.4.9 #3 Example' '#include "//e"'    "preprocessor(#include \"//e\"
)"
test_lex '6.4.9 #3 Example' '// */'             "comment(// */
)"
test_lex '6.4.9 #3 Example' 'f = g/**//h;'      "identifier(f)
whitespace( )
punctuator(=)
whitespace( )
identifier(g)
comment(/**/)
punctuator(/)
identifier(h)
punctuator(;)"
test_lex '6.4.9 #3 Example' "//\\
i();" "comment(//\\
i();
)"
test_lex '6.4.9 #3 Example' "/\\
/ j();" "comment(/\\
/ j();
)"
test_lex '6.4.9 #3 Example' "/*//*/ l();" "comment(/*//*/)
whitespace( )
identifier(l)
punctuator(()
punctuator())
punctuator(;)"
test_lex '6.4.9 #3 Example' "m=n//**/o
+ p;" "identifier(m)
punctuator(=)
identifier(n)
comment(//**/o
)
punctuator(+)
whitespace( )
identifier(p)
punctuator(;)"
test_lex '6.4.9 #3 Multiline test 1' "/\\
/\\
//" "comment(/\\
/\\
//
)"
test_lex '6.4.9 #3 Multiline test 1' "/\\
/\\
//
/\\
/" "comment(/\\
/\\
//
/\\
/
)"
test_lex "? preprocessor (#include h-chars)" '#include "<foo>"' "preprocessor(#include \"<foo>\"
)"
test_lex "? preprocessor (#include q-chars)" '#include <"foo">' "preprocessor(#include <\"foo\">
)"
test_lex "? macro lone #" "#" "preprocessor(#
)"
test_lex "? macro # and \\" "#\\
" "preprocessor(#\\

)"
test_lex "? macro (multi \\ lines)" "#\\
\\
" "preprocessor(#\\
\\

)"
test_lex '? macro (simple #define)' "#define X" "preprocessor(#define X
)"
test_lex '? macro (#define and \\)' "#define X \\
Y" "preprocessor(#define X \\
Y
)"

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

