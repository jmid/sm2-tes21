#include <stdio.h>
#include <stdlib.h>

int main()
{
  char *p = malloc(5);
  p[0] = 'h';
  p[1] = 'e';
  p[2] = 'l';
  p[3] = 'l';
  p[4] = 'o';
  p[5] = '\0'; /* this index is out of bounds */
  printf("%s\n",p);
  return 0;
}
