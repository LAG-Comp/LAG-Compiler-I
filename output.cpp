#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main() {
  int temp_bool_1;

	int a;
	int b;


  a = 10;


  b = 15;

  temp_bool_1 = a < b;
	if( !temp_bool_1 ) goto L_if_end_1;
		printf( "%d" , a );
	printf( "%s" , "\n" );


	L_if_end_1:
		printf( "%s" , "\n" );


	L_if_chain_end_1:

	return 0;
}

