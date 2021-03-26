/* example from Building Secure and Reliable Systems, Chap.13
   https://landing.google.com/sre/books/ */
#include <stdlib.h>

int main() {
  char *x = (char*)calloc(10, sizeof(char));
  free(x);
  return x[5];
}
