#include <stdio.h>
#include <stdlib.h>
#include <string.h>

	int mat[30];
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
	
	L_if_chain_end_2:

	return resultado;
}


int main() {
	int temp_bool_1;
	int temp_bool_2;
	int temp_bool_3;
	int temp_bool_4;
	int temp_int_1;
	int temp_int_2;
	int temp_int_3;
	int temp_int_4;

	int a;
	int ghf;


	temp_bool_3 = 4 < 6;
	temp_bool_4 = !temp_bool_3;
	ghf = temp_bool_4;


	a = 1;

	temp_int_1 = a * 10;
	temp_int_2 = temp_int_1 + 3;
	mat[temp_int_2] = 5;

	temp_int_3 = 10 * 2;
	temp_int_4 = temp_int_3 + 3;
	a = mat[temp_int_4];

	return 0;
}

