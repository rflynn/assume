/* <##c blargg> For example, FILE* f = (FILE*) malloc( 1234 ); fclose( f ); */

#include <stdio.h>
int main(void)
{
  FILE* f = malloc(1);
  fclose(f);
  return 0;
}

