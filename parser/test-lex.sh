#!/bin/bash

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


echo "FIXME: cpp multiline \ stuff broken, fix"

echo "6.4.9 Comments"
test_lex '6.4.9 Comments (c-style)' "/**/" "comment(/**/)
newline(
)"
test_lex '6.4.9 Comments (c-style)' "/**** */" "comment(/**** */)
newline(
)"
test_lex '6.4.9 Comments (c-style)' "/* */" "comment(/* */)
newline(
)"
test_lex '6.4.9 Comments (c-style)' "/* /* */ */" "comment(/* /* */ */)
newline(
)"
test_lex '6.4.9 Comments (cplusplus easy)' "//" "comment(//
)"
test_lex '6.4.9 Comments (nested cplusplus)' '/*//*/' "comment(/*//*/)
newline(
)"
test_lex '6.4.9 Comments (nested c)' '///* */' "comment(///* */
)"
test_lex '6.4.9 Comments c-style, string nested' '"/**/"' 'string_literal("/**/")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"//"' 'string_literal("//")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"/"' 'string_literal("/")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"///"' 'string_literal("///")
newline(
)'
test_lex '6.4.9 #3 Example' '"a//b"'            'string_literal("a//b")
newline(
)'
test_lex '6.4.9 #3 Example' '#include "//e"'    "preprocessor(#include \"//e\"
)"
test_lex '6.4.9 #3 Example' '// */'             "comment(// */
)"
test_lex '6.4.9 #3 Example' 'f = g/**//h;'      "identifier(f)
whitespace( )
=
whitespace( )
identifier(g)
comment(/**/)
/
identifier(h)
;
newline(
)"
#test_lex '6.4.9 #3 Example' "//\\
#i();" "comment(//\\
#i();
#)"
#test_lex '6.4.9 #3 Example' "/\\
#/ j();" "comment(/\\
#/ j();
#)"
test_lex '6.4.9 #3 Example' "/*//*/ l();" "comment(/*//*/)
whitespace( )
identifier(l)
(
)
;
newline(
)"
test_lex '6.4.9 #3 Example' "m=n//**/o
+ p;" "identifier(m)
=
identifier(n)
comment(//**/o
)
+
whitespace( )
identifier(p)
;
newline(
)"
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
test_lex "? preprocessor (#include h-chars)" '#include "<foo>"' "preprocessor(#include \"<foo>\"
)"
test_lex "? preprocessor (#include q-chars)" '#include <"foo">' "preprocessor(#include <\"foo\">
)"
test_lex "? macro lone #" "#" "preprocessor(#
)"
#test_lex "? macro # and \\" "#\\
#" "preprocessor(#\\
#
#)"
#test_lex "? macro (multi \\ lines)" "#\\
#\\
#" "preprocessor(#\\
#\\
#
#)"
#test_lex '? macro (simple #define)' "#define X" "preprocessor(#define X
#)"
#test_lex '? macro (#define and \\)' "#define X \\
#Y" "preprocessor(#define X \\
#Y
#)"



test_lex 'Whitespace' ' '       'whitespace( )
newline(
)'
test_lex 'Whitespace' "a b"     "identifier(a)
whitespace( )
identifier(b)
newline(
)"
#test_lex 'Whitespace' "\f"      "whitespace(\f)"
#test_lex 'Whitespace' "\v"      "whitespace(\v)"
#test_lex 'Whitespace' "\r"      "whitespace(\r)"

echo "6.4.6 Punctuators"
test_lex '6.4.6 Punctuators'  '['       '[
newline(
)'
test_lex '6.4.6 Punctuators'  ']'       ']
newline(
)'
test_lex '6.4.6 Punctuators'  '.'       '.
newline(
)'
test_lex '6.4.6 Punctuators'  '->'      '->
newline(
)'
test_lex '6.4.6 Punctuators'  '>>='     '>>=
newline(
)'
test_lex '6.4.6 Punctuators'  '&&&&&'   "&&
&&
&
newline(
)"
#test_lex '6.4.6 Punctuators'  '##'      '##'
test_lex '6.4.6 Punctuators'  '+'       '+
newline(
)'
test_lex '6.4.6 Punctuators'  '++'      '++
newline(
)'
test_lex '6.4.6 Punctuators'  '+++'     '++
+
newline(
)'
test_lex '6.4.6 Punctuators'  '--'      '--
newline(
)'
test_lex '6.4.6 Punctuators'  '--->>>'  "--
->
>>
newline(
)"
test_lex '6.4.6 Punctuators'  '<<<===>>>' "<<
<=
==
>>
>
newline(
)"
# The program fragment x+++++y is parsed as x ++ ++ + y,
test_lex '6.4.1 Example 2' 'x+++++y'  'identifier(x)
++
++
+
identifier(y)
newline(
)'



echo "6.4.2 Identifiers"
test_lex '6.4.2 Identifiers' '_'                      'identifier(_)
newline(
)'
test_lex '6.4.2 Identifiers' '__'                     'identifier(__)
newline(
)'
test_lex '6.4.2 Identifiers' '___'                    'identifier(___)
newline(
)'
test_lex '6.4.2 Identifiers' '_____________________'  'identifier(_____________________)
newline(
)'
test_lex '6.4.2 Identifiers' '__FILE__'               'identifier(__FILE__)
newline(
)'
test_lex '6.4.2 Identifiers' '__LINE__'               'identifier(__LINE__)
newline(
)'
test_lex '6.4.2 Identifiers' '__func__'               'identifier(__func__)
newline(
)'
test_lex '6.4.2 Identifiers' 'a'                      'identifier(a)
newline(
)'
test_lex '6.4.2 Identifiers' '_0'                     'identifier(_0)
newline(
)'
test_lex '6.4.2 Identifiers' '_a0'                    'identifier(_a0)
newline(
)'
test_lex '6.4.2 Identifiers' '_a0a'                   'identifier(_a0a)
newline(
)'

echo "6.4.3 Universal character names"
test_lex '6.4.2 Identifiers' '_\u0123'                'identifier(_\u0123)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\u4567'                'identifier(a\u4567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\u0123\u4567'          'identifier(a\u0123\u4567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\U01234567'            'identifier(a\U01234567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\U01234567\u9ABC'      'identifier(a\U01234567\u9ABC)
newline(
)'
test_lex '6.4.2 Identifiers' '_\U89ABCDEF\u9ABC'      'identifier(_\U89ABCDEF\u9ABC)
newline(
)'

echo "6.4.4.3 Enum constants"
 
echo "6.4.5 Character constants"
test_lex '6.4.5 Character constants'  "''"          "character_constant('')
newline(
)"
test_lex '6.4.5 Character constants'  "L''"         "character_constant(L'')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x0'"       "character_constant('\\x0')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x00'"      "character_constant('\\x00')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x000'"     "character_constant('\\x000')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x0000'"    "character_constant('\\x0000')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\a'"        "character_constant('\\a')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\b'"        "character_constant('\\b')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\f'"        "character_constant('\\f')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\n'"        "character_constant('\\n')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\r'"        "character_constant('\\r')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\t'"        "character_constant('\\t')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\v'"        "character_constant('\\v')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\xA\\xB'"    "character_constant('\\xA\\xB')
newline(
)"
test_lex '6.4.5 empty string'         '""'          'string_literal("")
newline(
)'
test_lex '6.4.5 empty wide string'    'L""'         'string_literal(L"")
newline(
)'
test_lex '6.4.5 string'               '"a"'         'string_literal("a")
newline(
)'
test_lex '6.4.5 string escape'        '"\\\\"'      'string_literal("\\\\")
newline(
)'
test_lex '6.4.5 string escape'        '"\\\""'      'string_literal("\\\"")
newline(
)'

echo "6.4.1 Keywords"
test_lex '6.4.1 Keywords' 'auto'        'keyword(auto)
newline(
)'
test_lex '6.4.1 Keywords' 'break'       'keyword(break)
newline(
)'
test_lex '6.4.1 Keywords' 'case'        'keyword(case)
newline(
)'
test_lex '6.4.1 Keywords' 'char'        'keyword(char)
newline(
)'
test_lex '6.4.1 Keywords' 'const'       'keyword(const)
newline(
)'
test_lex '6.4.1 Keywords' 'continue'    'keyword(continue)
newline(
)'
test_lex '6.4.1 Keywords' 'default'     'keyword(default)
newline(
)'
test_lex '6.4.1 Keywords' 'do'          'keyword(do)
newline(
)'
test_lex '6.4.1 Keywords' 'double'      'keyword(double)
newline(
)'
test_lex '6.4.1 Keywords' 'else'        'keyword(else)
newline(
)'
test_lex '6.4.1 Keywords' 'enum'        'keyword(enum)
newline(
)'
test_lex '6.4.1 Keywords' 'extern'      'keyword(extern)
newline(
)'
test_lex '6.4.1 Keywords' 'float'       'keyword(float)
newline(
)'
test_lex '6.4.1 Keywords' 'for'         'keyword(for)
newline(
)'
test_lex '6.4.1 Keywords' 'goto'        'keyword(goto)
newline(
)'
test_lex '6.4.1 Keywords' 'if'          'keyword(if)
newline(
)'
test_lex '6.4.1 Keywords' 'inline'      'keyword(inline)
newline(
)'
test_lex '6.4.1 Keywords' 'int'         'keyword(int)
newline(
)'
test_lex '6.4.1 Keywords' 'long'        'keyword(long)
newline(
)'
test_lex '6.4.1 Keywords' 'register'    'keyword(register)
newline(
)'
test_lex '6.4.1 Keywords' 'restrict'    'keyword(restrict)
newline(
)'
test_lex '6.4.1 Keywords' 'return'      'keyword(return)
newline(
)'
test_lex '6.4.1 Keywords' 'short'       'keyword(short)
newline(
)'
test_lex '6.4.1 Keywords' 'signed'      'keyword(signed)
newline(
)'
test_lex '6.4.1 Keywords' 'sizeof'      'keyword(sizeof)
newline(
)'
test_lex '6.4.1 Keywords' 'static'      'keyword(static)
newline(
)'
test_lex '6.4.1 Keywords' 'struct'      'keyword(struct)
newline(
)'
test_lex '6.4.1 Keywords' 'switch'      'keyword(switch)
newline(
)'
test_lex '6.4.1 Keywords' 'typedef'     'keyword(typedef)
newline(
)'
test_lex '6.4.1 Keywords' 'union'       'keyword(union)
newline(
)'
test_lex '6.4.1 Keywords' 'unsigned'    'keyword(unsigned)
newline(
)'
test_lex '6.4.1 Keywords' 'void'        'keyword(void)
newline(
)'
test_lex '6.4.1 Keywords' 'volatile'    'keyword(volatile)
newline(
)'
test_lex '6.4.1 Keywords' 'while'       'keyword(while)
newline(
)'
test_lex '6.4.1 Keywords' '_Bool'       'keyword(_Bool)
newline(
)'
test_lex '6.4.1 Keywords' '_Complex'    'keyword(_Complex)
newline(
)'
test_lex '6.4.1 Keywords' '_Imaginary'  'keyword(_Imaginary)
newline(
)'

echo "6.4.4 Constants"

echo "6.4.4.1 Integer constants"
test_lex '6.4.4.1 Octal'    '0'       'integer_constant(0)
newline(
)'
test_lex '6.4.4.1 Octal'    '00'      'integer_constant(00)
newline(
)'
test_lex '6.4.4.1 Octal'    '01'      'integer_constant(01)
newline(
)'
test_lex '6.4.4.1 Octal'    '02'      'integer_constant(02)
newline(
)'
test_lex '6.4.4.1 Octal'    '03'      'integer_constant(03)
newline(
)'
test_lex '6.4.4.1 Octal'    '04'      'integer_constant(04)
newline(
)'
test_lex '6.4.4.1 Octal'    '05'      'integer_constant(05)
newline(
)'
test_lex '6.4.4.1 Octal'    '06'      'integer_constant(06)
newline(
)'
test_lex '6.4.4.1 Octal'    '07'      'integer_constant(07)
newline(
)'
test_lex '6.4.4.1 Octal'    '08'      'integer_constant(0)
integer_constant(8)
newline(
)'
test_lex '6.4.4.1 Octal'    '09'      'integer_constant(0)
integer_constant(9)
newline(
)'
test_lex '6.4.4.1 Octal'    '0A'      'integer_constant(0)
identifier(A)
newline(
)'
test_lex '6.4.4.1 Octal'    '8'      'integer_constant(8)
newline(
)'
test_lex '6.4.4.1 Octal'    '9'      'integer_constant(9)
newline(
)'
test_lex '6.4.4.1 Octal'    '0u'      'integer_constant(0u)
newline(
)'
test_lex '6.4.4.1 Octal'    '0U'      'integer_constant(0U)
newline(
)'
test_lex '6.4.4.1 Octal'    '0UL'     'integer_constant(0UL)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ul'     'integer_constant(0ul)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ULL'    'integer_constant(0ULL)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ull'    'integer_constant(0ull)
newline(
)'
test_lex '6.4.4.1 Octal'    '0Ull'    'integer_constant(0Ull)
newline(
)'
test_lex '6.4.4.1 Octal'    '0uLL'    'integer_constant(0uLL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1'       'integer_constant(1)
newline(
)'
test_lex '6.4.4.1 Decimal'  '2'       'integer_constant(2)
newline(
)'
test_lex '6.4.4.1 Decimal'  '3'       'integer_constant(3)
newline(
)'
test_lex '6.4.4.1 Decimal'  '4'       'integer_constant(4)
newline(
)'
test_lex '6.4.4.1 Decimal'  '5'       'integer_constant(5)
newline(
)'
test_lex '6.4.4.1 Decimal'  '6'       'integer_constant(6)
newline(
)'
test_lex '6.4.4.1 Decimal'  '7'       'integer_constant(7)
newline(
)'
test_lex '6.4.4.1 Decimal'  '8'       'integer_constant(8)
newline(
)'
test_lex '6.4.4.1 Decimal'  '9'       'integer_constant(9)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1u'      'integer_constant(1u)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1U'      'integer_constant(1U)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1UL'     'integer_constant(1UL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ul'     'integer_constant(1ul)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ULL'    'integer_constant(1ULL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ull'    'integer_constant(1ull)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1Ull'    'integer_constant(1Ull)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1uLL'    'integer_constant(1uLL)
newline(
)'

echo "6.4.4.2 Floating constants"
test_lex '6.4.4.2 Floating constant'        '0.'                'floating_constant(0.)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.0'               'floating_constant(0.0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '.0'                'floating_constant(.0)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.f'               'floating_constant(0.f)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.l'               'floating_constant(0.l)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.F'               'floating_constant(0.F)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.L'               'floating_constant(0.L)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'floating_constant(0.1f)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'floating_constant(0.1f)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x0.0p+0'          'floating_constant(0x0.0p+0)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x1.1p-1'          'floating_constant(0x1.1p-1)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x2.2p-2f'         'floating_constant(0x2.2p-2f)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.3p-3L'         'floating_constant(0x3.3p-3L)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.243F6A88p+03'  'floating_constant(0x3.243F6A88p+03)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e0'               'floating_constant(0e0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e+0'              'floating_constant(0e+0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e-0'              'floating_constant(0e-0)
newline(
)'
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

