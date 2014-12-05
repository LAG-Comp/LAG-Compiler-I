#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int MDC(int n, int m);


int MDC(int n, int m){
	int a;
	int b;
	int resultado;


	temp_bool_1 = n > m;
	temp_bool_1= !temp_bool_1;
	if( temp_bool_1 ) goto L_if_end_1;
		a = n;

	b = m;


	L_if_end_1:
		a = m;

	b = n;


	L_if_chain_end_1:

	temp_bool_2 = b == 0;
	temp_bool_2= !temp_bool_2;
	if( temp_bool_2 ) goto L_if_end_2;
		resultado = m;


	L_if_end_2:
		resultado = MDC(a,b);
;


	L_if_chain_end_2:

	return resultado;
}


int main() {
	int temp_bool_1;
	int temp_bool_2;

	int a;
	int b;
	int res;




	printf( "%s" , "Digite dois inteiros, por favor: \n" );

	scanf( "%d" , &a );

	scanf( "%d" , &b );

	res = MDC(a,b);
;

	printf( "%s" , "MDC entre os dois: " );
	printf( "%d" , res );
	printf( "%s" , "\n" );

	return 0;
}

