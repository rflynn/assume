int a = 0;
/* EASY bug: assignment in if clause */
/* REAL bug: test of constant, since we know
   a = 1 is always 1 and 1 is a constant,
   why are we testing it? this is the sort of
   deeper analysis we NEED to be able to do */
if ((a = 1)){}
