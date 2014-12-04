#include <stdio.h>
#include <stdlib.h>
#include <string.h>

	int aba;
	char uhuu[256];

int main() {
	int temp_bool_1;
	int temp_bool_2;

	int a;
	int b;
	int i;


  a = 10;


  b = 15;

  temp_bool_1 = a < b;
	temp_bool_1= !temp_bool_1;
	if( temp_bool_1 ) goto L_if_end_1;
		printf( "%d" , a );
	printf( "%s" , "\n" );


	L_if_end_1:
		printf( "%s" , "\n" );


	L_if_chain_end_1:

	i = 0;
	L_cond_for_1:
	temp_bool_2 = i < 19;
	temp_bool_2 = !temp_bool_2;
	if( temp_bool_2 ) goto L_end_for_1;

	printf( "%d" , i );
	printf( "%s" , "\n" );


	i= 1 + i;
	goto L_cond_for_1;
	L_end_for_1:


	return 0;
}

