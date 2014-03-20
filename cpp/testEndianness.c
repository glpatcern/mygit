#include <stdio.h>

int am_big_endian()
{
  long one= 1;
  return !(*((char *)(&one)));
}
 
 
int main()
{
  printf("Test Endianness: this system is %s endian.\n", (am_big_endian() ? "BIG" : "LITTLE"));
  printf("htons(1) returns %d.\n", htons(1));
  return 0;
}
