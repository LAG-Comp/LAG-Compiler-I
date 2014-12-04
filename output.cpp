#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
  int temp_bool_1;

	int a;

  a = 10;

	int i;
	i = a;
	L_cond_for_1:
	temp_bool_1 = !( i < 15 );
	if( temp_bool_1 ) goto L_end_for_1;

	printf( "%d" , i );
	printf( "%s" , "\n" );


	i++;
	goto L_cond_for_1;
	L_end_for_1:


	return 0;
}

