/**
 * according to (something?!) the results of malloc(0) are implementation-defined
 */
#include <stdlib.h>
int main(void)
{
  void *foo = malloc(0);
  return 0;
}
