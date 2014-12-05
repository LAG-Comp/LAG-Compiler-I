#include <stdio.h>
#include <stdlib.h>
#include <string.h>

	int aba;
	int arr2[8];
	char mat[5120];

int main() {
	int temp_bool_1;
	int temp_bool_2;
	int temp_bool_3;
	int temp_bool_4;

	int a;
	int arr[8];
	int b;
	int i;


  a = 10;


  temp_bool_1 = 5 > 8;
	temp_bool_1= !temp_bool_1;
	if( temp_bool_1 ) goto L_while_end_1;
	  a = 3;


L_while_end_1:

L_do_while_begin_1:
	  a = 2;


	  temp_bool_2 = 4 < 7;
	if( temp_bool_2 ) goto L_do_while_begin_1;


  b = 15;

  temp_bool_3 = a < b;
	temp_bool_3= !temp_bool_3;
	if( temp_bool_3 ) goto L_if_end_1;
		printf( "%d" , a );
	printf( "%s" , "\n" );


	L_if_end_1:
		printf( "%s" , "\n" );


	L_if_chain_end_1:

	i = 0;
	L_cond_for_1:
	temp_bool_4 = i < 19;
	temp_bool_4 = !temp_bool_4;
	if( temp_bool_4 ) goto L_end_for_1;

	printf( "%d" , i );
	printf( "%s" , "\n" );


	i= 1 + i;
	goto L_cond_for_1;
	L_end_for_1:


	return 0;
}

