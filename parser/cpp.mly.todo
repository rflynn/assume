Put this shit in c99.mly when i'm ready for it; trying to get plain C working first.

/* A.3 Preprocessing directives */
preprocessing_file:
  /* empty */ {}
  | group {}
  ;

group:
  group_part {}
  | group group_part {}
  ;

group_part:
  if_section {}
  | control_line {}
  | text_line {}
  | "#" non_directive {}
  ;

if_section:
  if_group elif_groups else_group endif_line {}
  | if_group elif_groups endif_line {}
  | if_group else_group endif_line {}
  | if_group endif_line {}
  ;

if_group:
  "#" IF constant_expr "\n" group {}
  | "#" IF constant_expr "\n" {}
  | "#" "ifdef" IDENTIFIER "\n" group {}
  | "#" "ifdef" IDENTIFIER "\n" {}
  | "#" "ifndef" IDENTIFIER "\n" group {}
  | "#" "ifndef" IDENTIFIER "\n" {}
  ;

elif_groups:
  elif_group {}
  | elif_groups elif_group {}
  ;

elif_group:
  "#" "elif" constant_expr "\n" group {}
  | "#" "elif" constant_expr "\n" {}
  ;

else_group:
  "#" ELSE "\n" group {}
  | "#" ELSE "\n" {}
  ;

endif_line:
  "#" "endif" "\n" {}
  ;

control_line:
  "#" "include" pp_tokens "\n" {}
  | "#" "define" IDENTIFIER replacement_list "\n" {}
  | "#" "define" IDENTIFIER lparen identifier_list ")" {}
  | "#" "define" IDENTIFIER lparen ")" {}
  | replacement_list "\n" {}
  | "#" "define" IDENTIFIER lparen "..." ")" replacement_list "\n" {}
  | "#" "define" IDENTIFIER lparen identifier_list "," "..." ")" {}
  | replacement_list "\n" {}
  | "#" "undef" IDENTIFIER "\n" {}
  | "#" "line" pp_tokens "\n" {}
  | "#" "error" pp_tokens "\n" {}
  | "#" "error" "\n" {}
  | "#" "pragma" pp_tokens "\n" {}
  | "#" "pragma" "\n" {}
  | "#" "\n" {}
  ;

text_line:
  pp_tokens "\n" {}
  | "\n" {}
  ;

non_directive:
  pp_tokens "\n" {}
  ;

lparen:
  "(" {}
  ;

replacement_list:
  /* empty */ {}
  | pp_tokens {}
  ;

pp_tokens:
  preprocessing_token {}
  | pp_tokens preprocessing_token {}
  ;

preprocessing_token:
  HEADER_NAME {}
  | IDENTIFIER {}
  | PP_NUMBER {}
  /*| character_constant {} */
  /*| string_literal {} */
  /*| punctuator {} */
  /*| each non_white_space character that cannot be one of the above */
  ;

%%

