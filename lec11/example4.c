#include <stdio.h>
#include <stdlib.h>


void f(char *p) {
  p[0] = 'h';
  p[1] = 'e';
  p[2] = 'l';
  p[3] = 'l';
  p[4] = 'o';
  p[5] = '\0'; /* this index is out of bounds */
}

int main()
{
  char p[5]; /* stack allocation */
  f(p);
  printf("%s\n",p);
  return 0;
}
