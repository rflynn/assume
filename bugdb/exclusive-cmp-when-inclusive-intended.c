/* possible bug: exclusive comparison should be inclusive */
/* NOTE: ionly trigger on common ranges like 'a'..'z', 'A'..'Z', '0'..'9', etc will produce fewer false positives */
  for (c = '0'; c < '9'; c++)
    match_add(c,  T_CONST_INT);

