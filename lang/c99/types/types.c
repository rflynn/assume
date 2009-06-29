/* Referemce ISO c98/99 standard S6.7.2 */

int main(void)
{
  /*  */
  void;
  char;
  char c;
  signed char cs;
  unsigned char cu;
  short s;
  unsigned short su;
  int i;
  unsigned int iu;
  signed int is;
  long l;
  unsigned long lu;
  long long ll;
  unsigned long long llu;
  float f;
  double d;
  long double dl;
  _Bool b;
  /* optional */
  float _Complex cf;
  double _Complex cd;
  long double _Complex cdl;
#if 0 /* GCC doesn't support */
  float _Imaginary if_;
  double _Imaginary id;
  long double _Imaginary idl;
#endif
  enum { E } e;
  /* composite types */
  struct { } st;
  union { } u;
  /* pointers */
  void *vp;
  char *cp;
  /* arrays */
#if 0
  void v[]; /* S6.7.5.2 #1 "The element type shall not be an incomplete or function
                            type." */
#endif
#if 0
  void v[*];  /* S6.7.5.2 #4 "If the size is * instead of being an expression,
                              the array type is a variable length array type of
                              unspecified size, which can only be used in
                              declarations with function prototype scope" */
#endif
#if 0
  char ca[]; /* requires initializer */
#endif
#if 0
  char ca[0]; /* S6.7.5.2 #1 "If the expression is a constant expression, it shall
                              have a value greater than zero. */
#endif
  char cas[1];
  char (cas2)[1];
#if 0
  char cas3[1][]; /* incomplete */
#endif
  char cas3[1][1]; /* incomplete */
  char *cas4[1];
  char (*cas5)[1];
  void vf();
#if 0
  void vf2()(); /* FIXME: what's wrong with this? */
#endif
  void *vfp();
#if 0
  void *vfp2()(); /* FIXME: can't return a function, eh? */
#endif
  void (*fpvp)();
#if 0
  void (*fpv)(...); /* named preceeding parameter required... */
#endif
  void (*fpv_e)();
  void (*fpv_v)(void);
#if 0
  void (*fpv_vv)(void,void);
#endif
  void (*fpv_cel)(char,...);  /* ellipsis */
  void (*fpv_static)(char[static 1]);
  return 0;
}

