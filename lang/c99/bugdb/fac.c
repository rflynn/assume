#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
unsigned factorial(unsigned n) 
{
  if (n <= 1) {
    return 1;
  } else {
    return n * factorial(n-1);
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
