/**
 * malloc is handed a size value that the type of pointer that is being assigned
 * cnanot fit in. a clear error.
 */
#include <stdlib.h>
int main(void)
{
  int *i = malloc(sizeof(int)-1); /* a write to *i is now garbage */
  return 0;
}
