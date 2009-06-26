/*
 * a (linked list) structure contains a pointer
 * (especially named "next") that does NOT
 * point to a defined location (NULL or proper type)
 */
struct node {
  int val;
  struct node *next;
};
static struct node * allocnode(int val)
{
  struct node *t = malloc(sizeof *t);
  /* WHOOPS: malloc can return NULL, and dereferencing NULL is UB! */
  t->val = val;
  /* WHOOPS: next unitialized */
  /* NOTE: this isn't really a bug per se, but we need to track
   * how this gets used
   */
  return t;
}
