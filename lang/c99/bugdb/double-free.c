#include <stdlib.h>
int main(void)
{
  /*& NOTE: try to catch silly malloc constant parameter too */
  void *m;
  m = malloc(0); 
  free(m);
  free(m);
  return 0;
}
