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
test_lex '6.4.9 Comments c-style, string nested' '"/**/"' 'str_lit("/**/")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"//"' 'str_lit("//")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"/"' 'str_lit("/")
newline(
)'
test_lex '6.4.9 Comments c++-style, string nested' '"///"' 'str_lit("///")
newline(
)'
test_lex '6.4.9 #3 Example' '"a//b"'            'str_lit("a//b")
newline(
)'
test_lex '6.4.9 #3 Example' '#include "//e"'    "cpp(#include \"//e\"
)"
test_lex '6.4.9 #3 Example' '// */'             "comment(// */
)"
test_lex '6.4.9 #3 Example' 'f = g/**//h;'      "ident(f)
whitespace( )
=
whitespace( )
ident(g)
comment(/**/)
/
ident(h)
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
ident(l)
(
)
;
newline(
)"
test_lex '6.4.9 #3 Example' "m=n//**/o
+ p;" "ident(m)
=
ident(n)
comment(//**/o
)
+
whitespace( )
ident(p)
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



test_lex 'Whitespace' ' '       'whitespace( )
newline(
)'
test_lex 'Whitespace' "a b"     "ident(a)
whitespace( )
ident(b)
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
test_lex '6.4.1 Example 2' 'x+++++y'  'ident(x)
++
++
+
ident(y)
newline(
)'



echo "6.4.2 Identifiers"
test_lex '6.4.2 Identifiers' '_'                      'ident(_)
newline(
)'
test_lex '6.4.2 Identifiers' '__'                     'ident(__)
newline(
)'
test_lex '6.4.2 Identifiers' '___'                    'ident(___)
newline(
)'
test_lex '6.4.2 Identifiers' '_____________________'  'ident(_____________________)
newline(
)'
test_lex '6.4.2 Identifiers' '__FILE__'               'ident(__FILE__)
newline(
)'
test_lex '6.4.2 Identifiers' '__LINE__'               'ident(__LINE__)
newline(
)'
test_lex '6.4.2 Identifiers' '__func__'               'ident(__func__)
newline(
)'
test_lex '6.4.2 Identifiers' 'a'                      'ident(a)
newline(
)'
test_lex '6.4.2 Identifiers' '_0'                     'ident(_0)
newline(
)'
test_lex '6.4.2 Identifiers' '_a0'                    'ident(_a0)
newline(
)'
test_lex '6.4.2 Identifiers' '_a0a'                   'ident(_a0a)
newline(
)'

echo "6.4.3 Universal character names"
test_lex '6.4.2 Identifiers' '_\u0123'                'ident(_\u0123)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\u4567'                'ident(a\u4567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\u0123\u4567'          'ident(a\u0123\u4567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\U01234567'            'ident(a\U01234567)
newline(
)'
test_lex '6.4.2 Identifiers' 'a\U01234567\u9ABC'      'ident(a\U01234567\u9ABC)
newline(
)'
test_lex '6.4.2 Identifiers' '_\U89ABCDEF\u9ABC'      'ident(_\U89ABCDEF\u9ABC)
newline(
)'

echo "6.4.4.3 Enum constants"
 
echo "6.4.5 Character constants"
test_lex '6.4.5 Character constants'  "''"          "char_lit('')
newline(
)"
test_lex '6.4.5 Character constants'  "L''"         "char_lit(L'')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x0'"       "char_lit('\\x0')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x00'"      "char_lit('\\x00')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x000'"     "char_lit('\\x000')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\x0000'"    "char_lit('\\x0000')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\a'"        "char_lit('\\a')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\b'"        "char_lit('\\b')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\f'"        "char_lit('\\f')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\n'"        "char_lit('\\n')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\r'"        "char_lit('\\r')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\t'"        "char_lit('\\t')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\v'"        "char_lit('\\v')
newline(
)"
test_lex '6.4.5 Character constants'  "'\\xA\\xB'"    "char_lit('\\xA\\xB')
newline(
)"
test_lex '6.4.5 empty string'         '""'          'str_lit("")
newline(
)'
test_lex '6.4.5 empty wide string'    'L""'         'str_lit(L"")
newline(
)'
test_lex '6.4.5 string'               '"a"'         'str_lit("a")
newline(
)'
test_lex '6.4.5 string escape'        '"\\\\"'      'str_lit("\\\\")
newline(
)'
test_lex '6.4.5 string escape'        '"\\\""'      'str_lit("\\\"")
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
test_lex '6.4.4.1 Octal'    '0'       'int_lit(0)
newline(
)'
test_lex '6.4.4.1 Octal'    '00'      'int_lit(00)
newline(
)'
test_lex '6.4.4.1 Octal'    '01'      'int_lit(01)
newline(
)'
test_lex '6.4.4.1 Octal'    '02'      'int_lit(02)
newline(
)'
test_lex '6.4.4.1 Octal'    '03'      'int_lit(03)
newline(
)'
test_lex '6.4.4.1 Octal'    '04'      'int_lit(04)
newline(
)'
test_lex '6.4.4.1 Octal'    '05'      'int_lit(05)
newline(
)'
test_lex '6.4.4.1 Octal'    '06'      'int_lit(06)
newline(
)'
test_lex '6.4.4.1 Octal'    '07'      'int_lit(07)
newline(
)'
test_lex '6.4.4.1 Octal'    '08'      'int_lit(0)
int_lit(8)
newline(
)'
test_lex '6.4.4.1 Octal'    '09'      'int_lit(0)
int_lit(9)
newline(
)'
test_lex '6.4.4.1 Octal'    '0A'      'int_lit(0)
ident(A)
newline(
)'
test_lex '6.4.4.1 Octal'    '8'      'int_lit(8)
newline(
)'
test_lex '6.4.4.1 Octal'    '9'      'int_lit(9)
newline(
)'
test_lex '6.4.4.1 Octal'    '0u'      'int_lit(0u)
newline(
)'
test_lex '6.4.4.1 Octal'    '0U'      'int_lit(0U)
newline(
)'
test_lex '6.4.4.1 Octal'    '0UL'     'int_lit(0UL)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ul'     'int_lit(0ul)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ULL'    'int_lit(0ULL)
newline(
)'
test_lex '6.4.4.1 Octal'    '0ull'    'int_lit(0ull)
newline(
)'
test_lex '6.4.4.1 Octal'    '0Ull'    'int_lit(0Ull)
newline(
)'
test_lex '6.4.4.1 Octal'    '0uLL'    'int_lit(0uLL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1'       'int_lit(1)
newline(
)'
test_lex '6.4.4.1 Decimal'  '2'       'int_lit(2)
newline(
)'
test_lex '6.4.4.1 Decimal'  '3'       'int_lit(3)
newline(
)'
test_lex '6.4.4.1 Decimal'  '4'       'int_lit(4)
newline(
)'
test_lex '6.4.4.1 Decimal'  '5'       'int_lit(5)
newline(
)'
test_lex '6.4.4.1 Decimal'  '6'       'int_lit(6)
newline(
)'
test_lex '6.4.4.1 Decimal'  '7'       'int_lit(7)
newline(
)'
test_lex '6.4.4.1 Decimal'  '8'       'int_lit(8)
newline(
)'
test_lex '6.4.4.1 Decimal'  '9'       'int_lit(9)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1u'      'int_lit(1u)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1U'      'int_lit(1U)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1UL'     'int_lit(1UL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ul'     'int_lit(1ul)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ULL'    'int_lit(1ULL)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1ull'    'int_lit(1ull)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1Ull'    'int_lit(1Ull)
newline(
)'
test_lex '6.4.4.1 Decimal'  '1uLL'    'int_lit(1uLL)
newline(
)'

echo "6.4.4.2 Floating constants"
test_lex '6.4.4.2 Floating constant'        '0.'                'float_lit(0.)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.0'               'float_lit(0.0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '.0'                'float_lit(.0)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.f'               'float_lit(0.f)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.l'               'float_lit(0.l)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.F'               'float_lit(0.F)
newline(
)'
test_lex '6.4.4.2 Floating constant suffix' '0.L'               'float_lit(0.L)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'float_lit(0.1f)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0.1f'              'float_lit(0.1f)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x0.0p+0'          'float_lit(0x0.0p+0)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x1.1p-1'          'float_lit(0x1.1p-1)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x2.2p-2f'         'float_lit(0x2.2p-2f)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.3p-3L'         'float_lit(0x3.3p-3L)
newline(
)'
test_lex '6.4.4.2 Floating constant (hex)'  '0x3.243F6A88p+03'  'float_lit(0x3.243F6A88p+03)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e0'               'float_lit(0e0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e+0'              'float_lit(0e+0)
newline(
)'
test_lex '6.4.4.2 Floating constant'        '0e-0'              'float_lit(0e-0)
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

