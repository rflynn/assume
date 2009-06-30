#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
unsigned factorial(unsigned n) 
{
  if (n <= 1) {
    return 1;
  } else {
    /* pre-calculate and store operand */
    unsigned m = factorial(n-1);
    /*
     * unsigned integers have a well-defined range.
     * multiplying two numbers n*m such that MAX / n < m
     * will result in overflow and an undefined result.
     */
    if (UINT_MAX / m < n) {
      fprintf(stderr, "Overflow.\n");
      exit(1);
    }
    return n * m;
  }
}
int main(int argc, char *argv[])
{
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <n>\n", argv[0]);
    exit(1);
  } else {
    unsigned n = (unsigned)atoi(argv[1]);
    unsigned f = factorial(n);
    printf("!%u = %u\n", n, f);
  }
  return 0;
}
