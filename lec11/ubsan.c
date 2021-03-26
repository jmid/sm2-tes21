int main(int argc, char **argv) {
  int k = 2147483647;
  k = k + argc; /* argument count is 1 without cmdline arguments */
  return 0;
}
