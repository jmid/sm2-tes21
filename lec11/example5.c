#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) /* argc is an argument counter */
{
  char a[10]; /* stack allocation */
  a[5] = 0;
  printf("running %s  argc is %i\n", argv[0], argc);
  if (a[argc]) /* Reading uninitialized memory */
    printf("what? %c\n", a[argc]);
  return 0;
}
