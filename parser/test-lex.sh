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
  #echo "$id..."
  input=$2
  expect=$3
  #echo $input > lex.test
  #result=`ocaml lex.ml < lex.test 2>&1`
  #rm lex.test
  result=`echo $input | ocaml lex.ml 2>&1`
  if [ "$expect" == "$result" ]
  then
    PassCnt=$((PassCnt+1))
  else
    echo "Test $id failed:"
    echo -e "INPUT\n$input"
    echo -e "EXPECT\n$expect"
    echo -e "RESULT\n$result\n"
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

echo "Testing..."

#test_lex '? macro' '#' "preprocessor(#
#)"
#test_lex '? macro' "#\
#" "preprocessor(#\
#)"
#test_lex '? macro' '#\
#\
#' 'preprocessor(#\
#\
#)'
#test_lex '? macro' '#define X
#' 'preprocessor(#define X)'
#test_lex '? macro' '#define X \
#Y' 'preprocessor(#define X \
#Y)'

# how do we mix C comments and bash?
comment="/\* \*/"
#test_lex '?' "$comment" 'comment(/**/)\n'

test_lex '6.4.2 floating constant' '0.' 'floating_constant(0.)'
test_lex '6.4.2 floating constant' '0.0' 'floating_constant(0.0)'
test_lex '6.4.2 floating constant suffix' '0.f' 'floating_constant(0.f)'
test_lex '6.4.2 floating constant suffix' '0.l' 'floating_constant(0.l)'
test_lex '6.4.2 floating constant suffix' '0.F' 'floating_constant(0.F)'
test_lex '6.4.2 floating constant suffix' '0.L' 'floating_constant(0.L)'
test_lex '6.4.2 floating constant' '0.1f' 'floating_constant(0.1f)'
test_lex '6.4.2 floating constant' '0.1f' 'floating_constant(0.1f)'
test_lex '6.4.2 floating constant' '0x0.' 'floating_constant(0x0.)'
test_lex '6.4.2 floating constant' '0x0.A' 'floating_constant(0x0.A)'
test_lex '6.4.2 floating constant' '0x0.Af' 'floating_constant(0x0.Af)'
test_lex '6.4.2 floating constant' '0e0' 'floating_constant(0e0)'
test_lex '6.4.2 floating constant' '0e+0' 'floating_constant(0e+0)'
test_lex '6.4.2 floating constant' '0e-0' 'floating_constant(0e-0)'

test_lex '6.4.5 character constants' "''" "character_constant('')"
test_lex '6.4.5 character constants' "L''" "character_constant(L'')"
test_lex '6.4.5 character constants' "'\x0'" "character_constant('\x0')"
test_lex '6.4.5 character constants' "'\x00'" "character_constant('\x00')"
test_lex '6.4.5 character constants' "'\x000'" "character_constant('\x000')"
test_lex '6.4.5 character constants' "'\x0000'" "character_constant('\x0000')"
test_lex '6.4.5 character constants' "'\a'" "character_constant('\a')"
test_lex '6.4.5 character constants' "'\b'" "character_constant('\b')"
test_lex '6.4.5 character constants' "'\f'" "character_constant('\f')"
test_lex '6.4.5 character constants' "'\n'" "character_constant('\n')"
test_lex '6.4.5 character constants' "'\r'" "character_constant('\r')"
test_lex '6.4.5 character constants' "'\t'" "character_constant('\t')"
test_lex '6.4.5 character constants' "'\v'" "character_constant('\v')"
test_lex '6.4.5 character constants' "'\xA\xB'" "character_constant('\xA\xB')"

test_lex '6.4.5 empty string' '""' 'string_literal("")'
test_lex '6.4.5 empty wide string' 'L""' 'string_literal(L"")'
test_lex '6.4.5 string' '"a"' 'string_literal("a")'
test_lex '6.4.5 string escape' '"\\\\"' 'string_literal("\\\\")'
test_lex '6.4.5 string escape' '"\\""' 'string_literal("\\"")'

test_lex '6.4.6 punctuator' '[' 'punctuator([)'
test_lex '6.4.6 punctuator' ']' 'punctuator(])'
test_lex '6.4.6 punctuator' '.' 'punctuator(.)'
test_lex '6.4.6 punctuator' '->' 'punctuator(->)'
test_lex '6.4.6 punctuator' '>>=' 'punctuator(>>=)'
test_lex '6.4.6 punctuator' '##' 'punctuator(##)'
test_lex '6.4.6 punctuator' '+' 'punctuator(+)'
test_lex '6.4.6 punctuator' '++' 'punctuator(++)'
test_lex '6.4.6 punctuator' '+++' 'punctuator(++)
punctuator(+)'
test_lex '6.4.6 punctuator' '--' 'punctuator(--)'

test_lex '6.4.1 keywords' 'auto' 'keyword(auto)'
test_lex '6.4.1 keywords' 'break' 'keyword(break)'
test_lex '6.4.1 keywords' 'case' 'keyword(case)'
test_lex '6.4.1 keywords' 'char' 'keyword(char)'
test_lex '6.4.1 keywords' 'const' 'keyword(const)'
test_lex '6.4.1 keywords' 'continue' 'keyword(continue)'
test_lex '6.4.1 keywords' 'default' 'keyword(default)'
test_lex '6.4.1 keywords' 'do' 'keyword(do)'
test_lex '6.4.1 keywords' 'double' 'keyword(double)'
test_lex '6.4.1 keywords' 'else' 'keyword(else)'
test_lex '6.4.1 keywords' 'enum' 'keyword(enum)'
test_lex '6.4.1 keywords' 'extern' 'keyword(extern)'
test_lex '6.4.1 keywords' 'float' 'keyword(float)'
test_lex '6.4.1 keywords' 'for' 'keyword(for)'
test_lex '6.4.1 keywords' 'goto' 'keyword(goto)'
test_lex '6.4.1 keywords' 'if' 'keyword(if)'
test_lex '6.4.1 keywords' 'inline' 'keyword(inline)'
test_lex '6.4.1 keywords' 'int' 'keyword(int)'
test_lex '6.4.1 keywords' 'long' 'keyword(long)'
test_lex '6.4.1 keywords' 'register' 'keyword(register)'
test_lex '6.4.1 keywords' 'restrict' 'keyword(restrict)'
test_lex '6.4.1 keywords' 'return' 'keyword(return)'
test_lex '6.4.1 keywords' 'short' 'keyword(short)'
test_lex '6.4.1 keywords' 'signed' 'keyword(signed)'
test_lex '6.4.1 keywords' 'sizeof' 'keyword(sizeof)'
test_lex '6.4.1 keywords' 'static' 'keyword(static)'
test_lex '6.4.1 keywords' 'struct' 'keyword(struct)'
test_lex '6.4.1 keywords' 'switch' 'keyword(switch)'
test_lex '6.4.1 keywords' 'typedef' 'keyword(typedef)'
test_lex '6.4.1 keywords' 'union' 'keyword(union)'
test_lex '6.4.1 keywords' 'unsigned' 'keyword(unsigned)'
test_lex '6.4.1 keywords' 'void' 'keyword(void)'
test_lex '6.4.1 keywords' 'volatile' 'keyword(volatile)'
test_lex '6.4.1 keywords' 'while' 'keyword(while)'
test_lex '6.4.1 keywords' '_Bool' 'keyword(_Bool)'
test_lex '6.4.1 keywords' '_Complex' 'keyword(_Complex)'
test_lex '6.4.1 keywords' '_Imaginary' 'keyword(_Imaginary)'

test_lex '6.4.3 identifier' '_' 'identifier(_)'
test_lex '6.4.3 identifier' '__' 'identifier(__)'
test_lex '6.4.3 identifier' '___' 'identifier(___)'
test_lex '6.4.3 identifier' '_____________________' 'identifier(_____________________)'
test_lex '6.4.3 identifier' '__FILE__' 'identifier(__FILE__)'
test_lex '6.4.3 identifier' '__LINE__' 'identifier(__LINE__)'
test_lex '6.4.3 identifier' '__func__' 'identifier(__func__)'
test_lex '6.4.3 identifier' 'a' 'identifier(a)'
test_lex '6.4.3 identifier' '_0' 'identifier(_0)'
test_lex '6.4.3 identifier' '_a0' 'identifier(_a0)'
test_lex '6.4.3 identifier' '_a0a' 'identifier(_a0a)'
test_lex '6.4.3 identifier' 'a\u0123' 'identifier(a\u0123)'
test_lex '6.4.3 identifier' 'a\u0123\u4567' 'identifier(a\u0123\u4567)'
test_lex '6.4.3 identifier' 'a\U01234567' 'identifier(a\U01234567)'
test_lex '6.4.3 identifier' 'a\U01234567\u9ABC' 'identifier(a\U01234567\u9ABC)'

# The program fragment x+++++y is parsed as x ++ ++ + y,
test_lex '6.4.1 Example 2' 'x+++++y' 'identifier(x)
punctuator(++)
punctuator(++)
punctuator(+)
identifier(y)'

test_lex '6.4.4.1 integer no decimal' '.1' 'Unrecognized(.)
decimal_constant(1)'
test_lex '6.4.4.1 octal' '0' 'octal_constant(0)'
test_lex '6.4.4.1 octal' '00' 'octal_constant(00)'
test_lex '6.4.4.1 octal' '01' 'octal_constant(01)'
test_lex '6.4.4.1 octal' '02' 'octal_constant(02)'
test_lex '6.4.4.1 octal' '03' 'octal_constant(03)'
test_lex '6.4.4.1 octal' '04' 'octal_constant(04)'
test_lex '6.4.4.1 octal' '05' 'octal_constant(05)'
test_lex '6.4.4.1 octal' '06' 'octal_constant(06)'
test_lex '6.4.4.1 octal' '07' 'octal_constant(07)'
test_lex '6.4.4.1 octal' '08' 'octal_constant(0)
decimal_constant(8)'
test_lex '6.4.4.1 octal' '09' 'octal_constant(0)
decimal_constant(9)'
test_lex '6.4.4.1 octal' '0A' 'octal_constant(0)
identifier(A)'
test_lex '6.4.4.1 octal' '0u' 'octal_constant(0u)'
test_lex '6.4.4.1 octal' '0U' 'octal_constant(0U)'
test_lex '6.4.4.1 octal' '0UL' 'octal_constant(0UL)'
test_lex '6.4.4.1 octal' '0ul' 'octal_constant(0ul)'
test_lex '6.4.4.1 octal' '0ULL' 'octal_constant(0ULL)'
test_lex '6.4.4.1 octal' '0ull' 'octal_constant(0ull)'
test_lex '6.4.4.1 octal' '0Ull' 'octal_constant(0Ull)'
test_lex '6.4.4.1 octal' '0uLL' 'octal_constant(0uLL)'
test_lex '6.4.4.1 decimal' '1' 'decimal_constant(1)'
test_lex '6.4.4.1 decimal' '2' 'decimal_constant(2)'
test_lex '6.4.4.1 decimal' '3' 'decimal_constant(3)'
test_lex '6.4.4.1 decimal' '4' 'decimal_constant(4)'
test_lex '6.4.4.1 decimal' '5' 'decimal_constant(5)'
test_lex '6.4.4.1 decimal' '6' 'decimal_constant(6)'
test_lex '6.4.4.1 decimal' '7' 'decimal_constant(7)'
test_lex '6.4.4.1 decimal' '8' 'decimal_constant(8)'
test_lex '6.4.4.1 decimal' '9' 'decimal_constant(9)'
test_lex '6.4.4.1 decimal' '1u' 'decimal_constant(1u)'
test_lex '6.4.4.1 decimal' '1U' 'decimal_constant(1U)'
test_lex '6.4.4.1 decimal' '1UL' 'decimal_constant(1UL)'
test_lex '6.4.4.1 decimal' '1ul' 'decimal_constant(1ul)'
test_lex '6.4.4.1 decimal' '1ULL' 'decimal_constant(1ULL)'
test_lex '6.4.4.1 decimal' '1ull' 'decimal_constant(1ull)'
test_lex '6.4.4.1 decimal' '1Ull' 'decimal_constant(1Ull)'
test_lex '6.4.4.1 decimal' '1uLL' 'decimal_constant(1uLL)'


TotalCnt=$((PassCnt+FailCnt))

echo "Pass $PassCnt/$TotalCnt"

if [ $FailCnt -eq 0 ]
then
  echo "Passed."
else
  echo "Failed!!!"
fi

