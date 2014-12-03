#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
  int temp_bool_1;
  int temp_bool_2;
  int temp_int_1;

	int a;

	int b;

	bool c;

  temp_bool_1 = 5 == 7;
  c = temp_bool_1;

	int d;

  temp_int_1 = 5 * 8;
  d = temp_int_1;

  temp_bool_2 = a < b;
	if( !temp_bool_2 ) goto L_if_end_1;
	
	L_if_end_1:

	return 0;
}

