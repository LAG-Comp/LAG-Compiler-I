#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
  int temp_bool_1;
  int temp_bool_2;
  int temp_bool_3;
  int temp_int_1;

	int a;

	int b;

	int c;

  temp_bool_1 = 5 == 7;
  c = temp_bool_1;

	int d;

  temp_int_1 = 5 * 8;
  d = temp_int_1;

	int ds;
	ds = 5;
	L_cond_for_1:
	temp_bool_2 = !( ds < 8 );
	if( temp_bool_2 ) goto L_end_for_1;

	int dfg;

  dfg = 8;


	ds++;
	goto L_cond_for_1;
	L_end_for_1:


  temp_bool_3 = a < b;
	if( !temp_bool_3 ) goto L_if_end_1;
		int dfg2;

  dfg2 = 8;


	L_if_end_1:

	return 0;
}

