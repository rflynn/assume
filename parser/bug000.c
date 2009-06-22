/* infinite loop if *s != '\0' */
static int rgxlen(const char *s)
{
  int c = 0;
  while (*s)
    c += (*s != '\\');
  return c;
}

