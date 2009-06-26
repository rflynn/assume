#include <stdlib.h>
int main(void)
{
  void *m;
  m = malloc(1); 
  m = malloc(1); /* leak */
  free(m);
  return 0;
}
