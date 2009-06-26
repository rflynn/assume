/* probable bug: loop variable is not 0..n, but is not used within the loop body */
  for (c = '0'; c <= '9'; c++)
    match_add('0',  T_CONST_INT);

