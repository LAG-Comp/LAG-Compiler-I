#include <stdio.h>
#include <stdlib.h>
#include <string.h>

	int a;
	int ghf;
	int mat[30];

int main() {
	int temp_bool_1;
	int temp_bool_2;
	int temp_int_1;
	int temp_int_2;
	int temp_int_3;
	int temp_int_4;



	temp_bool_1 = 4 < 6;
	temp_bool_2 = !temp_bool_1;
	ghf = temp_bool_2;


	a = 1;

	temp_int_1 = a * 10;
	temp_int_2 = temp_int_1 + 3;
	mat[temp_int_2] = 5;

	temp_int_3 = 10 * 2;
	temp_int_4 = temp_int_3 + 3;
	a = mat[temp_int_4];

	return 0;
}

