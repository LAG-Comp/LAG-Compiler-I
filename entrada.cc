Global <integer> a, b;
b = 10 modulo (5 + 2 * 3 );
a = (a + b) * (1 + 10 * a);

Global <boolean> c;
c = true;
c = true and false;
c = true or false;

Global Array <integer> of size 3 arr;
Global Matrix <integer> of size 4 by 5 mat;

c = b is greater than a;
c = b is greater than or equal to a;


Load: my_function
Input: <integer> <copy> bca, <boolean> <reference> gbo
Output: <integer> ret
{
	<boolean> d;

	d = a is lesser than b;
	d = a is lesser than or equal to b;

	Array <integer> of size 3 arrl;
    Matrix <integer> of size 4 by 5 matl;

	<integer> f;
	f = Execute function one_function();

	Execute function other_function();
	Execute function other_function with( a, b );

	<boolean> e;

	e = not ( b is different from a );
	e = Execute function one_function();

	If b is lesser than or equal to a execute
	{
		dfg = Execute function uhuuu();
	}

	While a is lesser than or equal to b repeat
	{
		<integer> ab;
		Print ab;
		Print "hello!\n";
	}

	For pudim from 1 to 4 execute
	{
		Print pudim;
	}

}